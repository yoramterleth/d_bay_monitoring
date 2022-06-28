// rework for optical imagery
// define time period to look at 
var startDate = ee.Date('2015-01-01')//('2020-02-15') //('2021-02-15')
var endDate = ee.Date('2022-06-20') //('2020-11-15') //('2021-09-20')

var band_id = 'B11'
//define tiem step for median: as short as possible but needs stretching if long bad weather
var step = 1

// load color palettes from Github
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.viridis[7];

// cloud filtering function for sentinel 2 imagery
function maskS2clouds(image) {
  var qa = image.select('QA60');

  // Bits 10 and 11 are clouds and cirrus, respectively.
  var cloudBitMask = 1 << 10;
  var cirrusBitMask = 1 << 11;

  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
      .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

  return image.updateMask(mask).divide(10000);
}

var dataset = ee.ImageCollection('COPERNICUS/S2_SR')
                  .filterBounds(D_bay)
                  .filterDate(startDate, endDate)
                  // Pre-filter to get less cloudy granules.
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE',20))
                  .map(maskS2clouds);
                  
                  
////////////////////////////////////////
//the problem here is that in some instance i get zero as the mask values that are not replaced correctly

var visualization = {
  min: 0.0,
  max: 0.5,
  bands: ['B11', 'B11', 'B11'],
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
        }).get({key:'B11', defaultValue: -9999})
        
        print('dtaset',dataset.mean())
        print('test',test)
        

// function to apply a D_bay spatial reducer to the daily values
var get_spatial_mean = function(image){
  return ee.Image.constant(image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:'B11', defaultValue: -999}))};
        
        
var get_spatial_mean = function(image){
  var img_val = image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:'B11', defaultValue: -999})
  
  return ee.Image.constant(ee.Algorithms.If(img_val,img_val,-999))
};
        
// apply function 
var spatial_mean = dataset.map(get_spatial_mean);
print('spatial_mean',spatial_mean)

// define function to transform images to regular values 
var get_values = function(image){
  //var img_trans = image.multiply(ee.Image([0.00876539])) // finally apply radiometric factor
  var mean = image.reduceRegion({
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
  description:'temp_valuesB11',
  fileFormat: 'CSV'
});

// get the various acquisition dates 
var dates = ee.FeatureCollection(ee.ImageCollection('COPERNICUS/S2_SR')
                  .filterBounds(D_bay)
                  .filterDate(startDate, endDate)
                  // Pre-filter to get less cloudy granules.
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE',20))
    .reduceColumns(ee.Reducer.toList(), ["system:index"])
    .get('list')); 
print('dates',dates); 

// no direct csv printing of a list: transform to feature collection
var featureCollection_dates = ee.FeatureCollection(ee.List(dates)
                        .map(function(element){
                        return ee.Feature(null,{prop:element})}))


// export the dates to drive 
Export.table.toDrive({
collection: featureCollection_dates,
description: 'acquisition_dates',
fileFormat: 'CSV'
});


//define vis params for sed. load 
var visParams = {
  min: 0,
  max: 0.05,
  palette:palette
};

Map.addLayer(dataset.select('B11').median(),visParams,'cloud masked')

