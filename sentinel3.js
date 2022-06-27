// rework for optical imagery
// define time period to look at 
var startDate = ee.Date('2020-01-01')//('2020-02-15') //('2021-02-15')
var endDate = ee.Date('2022-05-20') //('2020-11-15') //('2021-09-20')

var band_id = 'Oa05_radiance'
//define tiem step for median: as short as possible but needs stretching if long bad weather
var step = 1

// load color palettes from Github
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.viridis[7];

// load sentinel3 data and filter it to date, bounds, and cloudiness 
var dataset = ee.ImageCollection('COPERNICUS/S3/OLCI')
                  .filterBounds(D_bay)
                  .filterDate(startDate, endDate);
                  
// check out what were dealing with 
print('Turbidity data: ' , dataset)

// cloud high brightness filter 
function checkBit(image, bit) {
      return image.bitwiseAnd(Math.pow(2, bit)).rightShift(bit);
         }
    function checkBitSentinel3(bit) {
      return function(image) {
        var q = image.select('quality_flags')
        var cloud= checkBit(q, bit).eq(0)
        return cloud
       }
    }
var cloud = dataset.map(checkBitSentinel3(27)).max();


// select band, apply correction, and apply the cloud mask
var cm_dataset = dataset.map(function(image){
  return image
    .select([band_id])
    .multiply(ee.Image([0.00876539]))
    .mask(cloud)
  }); 
  
print('cloud mask applied:', cm_dataset)

// define function that gets mean from daily interval
var get_interval_mean = function(dayOffset){
      var start = startDate.advance(dayOffset, 'days')
      var end = start.advance(step, 'days')  // adjust temporal resolution
      return  dataset.filterDate(start, end)
        .mean()
          }

// get total nb of days 
var numberOfDays = endDate.difference(startDate, 'days') 

// make a list of all the day offsets
var dayOffsets = ee.List.sequence(0, numberOfDays.subtract(step))
print('list of day offsets:', dayOffsets)

// make a new collection, that holds the average image vals for each day interval
var daily = ee.ImageCollection(dayOffsets.map(get_interval_mean));

var add_band = function(image){
    var fill_img = ee.Image.constant(-9999).select(['constant'], ['fill'])
  return image.addBands(fill_img)
  }

var b_daily = daily.map(add_band)

print('daily:', b_daily)

// select band, apply correction, and apply the cloud mask
var cm_daily = b_daily.map(function(image){
  return image
    //.select(['Oa07_radiance'])
    .multiply(ee.Image([0.00876539]))
    .mask(cloud)
  }); 

// 
// print(daily.first().reduceRegion({
//         geometry:D_bay,
//         reducer: ee.Reducer.mean(),
//         scale: 300 // the resolution of the GRIDMET dataset
//         }))

// function to apply a D_bay spatial reducer to the daily values
var get_spatial_mean = function(image){
  return ee.Image.constant((image.reduceRegion({
        geometry:D_bay,
        reducer: ee.Reducer.mean(),
        scale: 300 // the resolution of the GRIDMET dataset
        })).get({key:band_id, defaultValue: -9999}))};
        
// apply function 
var daily_mean = cm_daily.map(get_spatial_mean);
print('daily_mean',daily_mean)

// define function to transform images to regular values 
var get_values = function(image){
  //var img_trans = image.multiply(ee.Image([0.00876539])) // finally apply radiometric factor
  var mean = image.reduceRegion({
    geometry:D_bay,
    reducer: ee.Reducer.mean(),
    scale:300,
  });
  return image.set(mean)
};

// apply function 
var values = daily_mean.map(get_values)
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
  description:'turbidity_values_b5',
  fileFormat: 'CSV'
});




//define vis params for sed. load 
var visParams = {
  min: 0,
  max: 3,
  palette:palette
};

Map.addLayer(cm_dataset.first(),visParams,'cloud masked')

