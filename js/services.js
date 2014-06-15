angular.module('TIRApp.services', [])
  .factory('TIRAPIservice', function($http) {

    var TIRAPI = {};
    TIRAPI.user = {};

    TIRAPI.getTurnos = function() {
      return $http({
        method: 'POST', 
        url: '/cgi-bin/tir/countries'
      });
    }

    TIRAPI.login = function(user, pass) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/login?user=' + user + '&password=' + pass
      });
    }

    TIRAPI.getTurno = function(id) {
      return $http({
        method: 'JSONP', 
        url: 'http://ergast.com/api/f1/2013/drivers/'+ id +'/driverStandings.json?callback=JSON_CALLBACK'
      });
    }

    return TIRAPI;
  });
