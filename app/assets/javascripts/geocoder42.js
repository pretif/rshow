/*
var L = require('leaflet'),
	Util = require('../util');

module.exports = {
	class: L.Class.extend({
		options: {
			serviceUrl: 'http://localhost:3000/geocoder/'
		},

		initialize: function() {
		},

		geocode: function(query, cb, context) {
			//get three words and make a dot based string
			Util.getJSON(this.options.serviceUrl +'forward', {
				addr: query.split(/\s+/).join('.'),
			}, function(data) {
				var results = [], loc, latLng, latLngBounds;
				if (data.hasOwnProperty('geometry')) {
					latLng = L.latLng(data.geometry['lat'],data.geometry['lng']);
					latLngBounds = L.latLngBounds(latLng, latLng);
					results[0] = {
						name: data.words,
						bbox: latLngBounds,
						center: latLng
					};
				}

				cb.call(context, results);
			});
		},

		suggest: function(query, cb, context) {
			return this.geocode(query, cb, context);
		},

		reverse: function(location, scale, cb, context) {
			Util.getJSON(this.options.serviceUrl +'reverse', {
				coords: [location.lat,location.lng].join(',')
			}, function(data) {
				var results = [],loc,latLng,latLngBounds;
				if (data.status.status == 200) {
					latLng = L.latLng(data.geometry['lat'],data.geometry['lng']);
					latLngBounds = L.latLngBounds(latLng, latLng);
					results[0] = {
						name: data.words,
						bbox: latLngBounds,
						center: latLng
					};
				}
				cb.call(context, results);
			});
		}
	}),

	factory: function() {
		return new L.Control.Geocoder.Geocoder42();
	}
};

*/
