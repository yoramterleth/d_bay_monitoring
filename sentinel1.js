// rework for SAR imagery 
// define time period to look at 
var startDate = ee.Date('2019-01-01')//('2020-02-15') //('2021-02-15')
var endDate = ee.Date('2022-06-20') //('2020-11-15') //('2021-09-20')

// other criteria
var polarization = 'VH';
var vizMin = -25;
var vizMax = 5;

var customFilter = ee.Filter.and(
  ee.Filter.date(startDate, endDate),
  ee.Filter.eq('instrumentMode', 'IW'),
  //ee.Filter.equals('relativeOrbitNumber_start', 50),
  ee.Filter.eq('orbitProperties_pass', 'ASCENDING'),
  ee.Filter.listContains('transmitterReceiverPolarisation', polarization)
);

var dataset = ee.ImageCollection('COPERNICUS/S1_GRD')
    .filterBounds(D_bay)
    .filter(customFilter)
    .sort('system:time_start')
    .select(polarization);
    print(dataset)
    


// load color palettes from Github
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.viridis[7];




// use satial reducer to get an average over our selected polygon 
var test = dataset.first().reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:polarization, defaultValue: -999})
        
        
        print('test',test)
        

// function to apply a D_bay spatial reducer to the daily values
var get_spatial_mean = function(image){
  return ee.Image.constant(image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:polarization, defaultValue: -999}))};
        
        
var get_spatial_mean = function(image){
  var img_val = image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:polarization, defaultValue: -999})
  
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
  description:'valuesS1',
  fileFormat: 'CSV'
});

// get the various acquisition dates 
var dates = dataset
    .reduceColumns(ee.Reducer.toList(), ["system:index"])
    .get('list'); 
print('dates',dates); 

// no direct csv printing of a list: transform to feature collection
var featureCollection_dates = ee.FeatureCollection(ee.List(dates)
                        .map(function(element){
                        return ee.Feature(null,{prop:element})}))


// export the dates to drive 
Export.table.toDrive({
collection: featureCollection_dates,
folder: 'GEE_DBay',
description: 'acquisition_dates_S1',
fileFormat: 'CSV'
});


//define vis params for sed. load 
var visParams = {
  min: vizMin,
  max: vizMax,
  palette:palette
};

Map.addLayer(dataset.select(polarization).median(),visParams,'scattering')

