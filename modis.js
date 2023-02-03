// rework for optical imagery to look at turbidity reflecatnce in the red band 
// define time period to look at 
var startDate = ee.Date('2015-01-01')//('2020-02-15') //('2021-02-1')
var endDate = ee.Date('2022-09-20') //('2020-11-15') //('2021-09-20')

var band_id = 'sur_refl_b01'
//define tiem step for median: as short as possible but needs stretching if long bad weather
var step = 1

// load color palettes from Github
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.viridis[7];

// A function to mask out cloudy pixels.
var maskClouds = function(image) {
  // Select the QA band.
  var QA = image.select('state_1km')
  // Make a mask to get bit 10, the internal_cloud_algorithm_flag bit.
  var bitMask = 1 << 10;
  // Return an image masking out cloudy areas.
  return image.updateMask(QA.bitwiseAnd(bitMask).eq(0))
}

var dataset_1 = ee.ImageCollection('MODIS/061/MOD09GQ')
                  .filter(ee.Filter.date(startDate, endDate));
var terra = ee.ImageCollection("MODIS/061/MOD09GA"); 

var test = dataset_1.combine(terra)
.filterDate(startDate, endDate);
var dataset = test
.filterBounds(D_bay)
.map(maskClouds);


print(dataset)
                  
                  
////////////////////////////////////////

var visualization = {
  min: 0.0,
  max: 0.5,
  bands: [band_id,band_id,band_id],
};

//Map.setCenter(59.97999972335253,-139.55841573249833, 12);

Map.addLayer(dataset.first(), visualization, 'RGB');


                  
// check out what were dealing with 
print('Temp data: ' , dataset)

// use satial reducer to get an average over our selected polygon 
var test = dataset.first().reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:band_id, defaultValue: -9999})
        
        print('dtaset',dataset.mean())
        print('test',test)
        

// function to apply a D_bay spatial reducer to the daily values
var get_spatial_mean = function(image){
  return ee.Image.constant(image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:band_id, defaultValue: -999}))};
        
        
var get_spatial_mean = function(image){
  var img_val = image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:band_id, defaultValue: -999})
  
  return ee.Image.constant(ee.Algorithms.If(img_val,img_val,-999))
};
        
// apply function 
var spatial_mean = dataset.map(get_spatial_mean);
print('spatial_mean',spatial_mean)

// define function to transform images to regular values 
var get_values = function(image){
  var img_trans = image.multiply(ee.Image([0.0001])) // finally apply radiometric factor
  var mean = img_trans.reduceRegion({
    geometry:D_bay,
    reducer: ee.Reducer.mean(),
    scale:20,
  });
  return image.set(mean)
};

// apply function 
var values = spatial_mean.map(get_values)
//print('values',values)

// transform to list 
var val_list = values
    .reduceColumns(ee.Reducer.toList(), ["constant"])
    .get('list'); 
print('values list',val_list); 

// no direct csv printing of a list: transform to feature collection
var featureCollection = ee.FeatureCollection(ee.List(val_list)
                        .map(function(element){
                        return ee.Feature(null,{prop:element})}))


//Export.table.toDrive(ee.Element(chartArray));
Export.table.toDrive({
  collection: featureCollection,
  folder: 'GEE_DBay',
  description:'MODIS_turb',
  fileFormat: 'CSV'
});

// get the various acquisition dates 
var dates = dataset.reduceColumns(ee.Reducer.toList(), ["system:index"]).get('list'); 
print('dates',dates); 

// no direct csv printing of a list: transform to feature collection
var featureCollection_dates = ee.FeatureCollection(ee.List(dates)
                        .map(function(element){
                        return ee.Feature(null,{prop:element})}))


// export the dates to drive 
Export.table.toDrive({
collection: featureCollection_dates,
folder: 'GEE_DBay',
description: 'MODIS_acquisition_dates_turb',
fileFormat: 'CSV'
});


//define vis params for sed. load 
var visParams = {
  min: 0,
  max: 0.5,
  palette:palette
};

Map.addLayer(dataset.select(band_id).median(),visParams,'cloud masked')

