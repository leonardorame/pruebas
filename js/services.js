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

    // retrieve user info from server by passing a cookie
    // if cookie is expired redirect to login
    TIRAPI.retrieveUserInfo = function() {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/sessiondata'
      });
      return false;  
    }

    TIRAPI.getTurno = function(idturno) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/study?IdStudy=' + idturno
      });
    }

    return TIRAPI;
  });
