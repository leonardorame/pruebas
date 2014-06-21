angular.module('TIRApp.services', [])
  .factory('TIRAPIservice', function($http) {
    var TIRAPI = {};
    TIRAPI.user = {};
    TIRAPI.study = {};

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

    TIRAPI.saveStudy = function(report){
      TIRAPI.study.Report = report;
      return $http({
            method: 'POST',
            data: TIRAPI.study, 
            url: '/cgi-bin/tir/study',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            // without transformRequest posted data is json
            transformRequest: function(obj) {
                console.log(obj);
                var str = [];
                for(var p in obj)
                str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                return str.join("&");
            }
        });
    };

    // retrieve user info from server by passing a cookie
    // if cookie is expired redirect to login
    TIRAPI.retrieveUserInfo = function() {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/sessiondata'
      });
      return false;  
    }

    TIRAPI.getStudy = function(idstudy) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/study?IdStudy=' + idstudy
      });
    }

    return TIRAPI;
  });
