angular.module('TIRApp.services', [])
  .factory('TIRAPIservice', function($http) {

    var TIRAPI = {};
    TIRAPI.user = {};

    TIRAPI.getTurnos = function(filter) {
      return $http({
        method: 'POST', 
        params: filter,
        url: '/cgi-bin/tir/studies'
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
