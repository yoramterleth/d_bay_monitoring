// rework for optical imagery landsat 8 
// define time period to look at 
var startDate = ee.Date('2015-01-01')//('2020-02-15') //('2021-02-15')
var endDate = ee.Date('2022-06-20') //('2020-11-15') //('2021-09-20')

var band_id = 'B10'
//define tiem step for median: as short as possible but needs stretching if long bad weather
var step = 1

// load color palettes from Github
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.viridis[7];

//cloud mask for LS8
function maskL8sr(col) {
  // Bits 3 and 5 are cloud shadow and cloud, respectively.
  var cloudShadowBitMask = (1 << 3);
  var cloudsBitMask = (1 << 5);
  // Get the pixel QA band.
  var qa = col.select('pixel_qa');
  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
                 .and(qa.bitwiseAnd(cloudsBitMask).eq(0));
  return col.updateMask(mask);
}

// load image collecion 
var dataset = ee.ImageCollection('LANDSAT/LC08/C01/T1_SR')
                  .filterBounds(D_bay)
                  .filterDate(startDate, endDate)
                  .map(maskL8sr);
                  
// //LST in Celsius Degree bring -273.15
// //NB: In Kelvin don't bring -273.15
// function ST(thermal) {
//     var a= ee.Number(0.004);
//     var b= ee.Number(0.986);
//     var EM=fv.multiply(a).add(b).rename('EMM');
//     return thermal.expression(
//           '(Tb/(1 + (0.00115* (Tb / 1.438))*log(Ep)))-273.15', {
//           'Tb': thermal.select('B10'),
//           'Ep': EM.select('EMM')
//             }).rename('LST')};

// surfT = dataset.map(ST)

                  
//select thermal band 10(with brightness tempereature), no calculation and show it 
// var thermal= dataset.median().select('B10').multiply(0.1);
// var b10Params = {min: 291.918, max: 302.382, palette: ['blue', 
// 'white', 'green']};
// Map.addLayer(thermal, b10Params, 'thermal');                  

var visualization = {
  min: 260,
  max: 280,
  bands: ['B10', 'B10', 'B10'],
};

//Map.setCenter(59.97999972335253,-139.55841573249833, 12);

Map.addLayer(dataset.median().multiply(0.1), visualization, 'THERMAL BAND');


                  
// check out what were dealing with 
print('Temp data: ' , dataset)

// use satial reducer to get an average over our selected polygon 
var test = dataset.first().reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:'B10', defaultValue: -999})
        
        print('dtaset',dataset.mean())
        print('test',test)
        

// function to apply a D_bay spatial reducer to the daily values
// var get_spatial_mean = function(image){
//   return ee.Image.constant(image.reduceRegion({
//         geometry:D_bay,
//         reducer: ee.Reducer.mean(),
//         scale:20 // the resolution of the B11 data
//         }).get({key:'B11', defaultValue: -999}))};
        
        
var get_spatial_mean = function(image){
  var img_val = image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale:20 // the resolution of the B11 data
        }).get({key:'B10', defaultValue: -9999})
        
  
  
  return ee.Image.constant(ee.Algorithms.If(img_val,img_val,-9999)).multiply(0.1)
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
    scale:30,
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
  description:'temp_valuesB10_LS8',
  fileFormat: 'CSV'
});

// get the various acquisition dates 
var dates = dataset
    .reduceColumns(ee.Reducer.toList(), ["SENSING_TIME"])
    .get('list'); 
print('dates',dates); 

// no direct csv printing of a list: transform to feature collection
var featureCollection_dates = ee.FeatureCollection(ee.List(dates)
                        .map(function(element){
                        return ee.Feature(null,{prop:element})}))


// export the dates to drive 
Export.table.toDrive({
collection: featureCollection_dates,
description: 'acquisition_dates_LS8',
fileFormat: 'CSV'
});


//define vis params for sed. load 
var visParams = {
  min: 0,
  max: 0.05,
  palette:palette
};

Map.addLayer(dataset.select('B10').median(),visParams,'cloud masked')

