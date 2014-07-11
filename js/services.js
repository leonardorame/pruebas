angular.module('TIRApp.services', [])
  .factory('TIRAPIservice', function($http) {
    var TIRAPI = {};
    TIRAPI.user = {};
    TIRAPI.study = {};
    TIRAPI.template = {};

    TIRAPI.getTurnos = function(filter) {
      return $http({
        method: 'POST', 
        data: filter,
        url: '/cgi-bin/tir/studies'
      });
    }

    TIRAPI.getTemplates = function(filter) {
      return $http({
        method: 'POST', 
        params: filter,
        url: '/cgi-bin/tir/templates'
      });
    }

    TIRAPI.getPatients = function(filter) {
      return $http({
        method: 'POST', 
        params: filter,
        url: '/cgi-bin/tir/patients'
      });
    }

    TIRAPI.login = function(user, pass) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/login?user=' + user + '&password=' + pass
      });
    }

    TIRAPI.saveAudioStream = function(stream) {
      return $http({
            method: 'POST',
            url: '/cgi-bin/tir/audio',
            data: '',
            headers: {'Content-Type': undefined},
            transformRequest: function(data){
                var fd = new FormData();
                fd.append('file', stream);
                fd.append('IdStudy', TIRAPI.study.IdStudy);
                return fd;
            }
        });
    };

    TIRAPI.saveStudy = function(report){
      TIRAPI.study.Report = report;
      return $http({
            method: 'POST',
            data: TIRAPI.study, 
            url: '/cgi-bin/tir/study',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            // without transformRequest posted data is json
            transformRequest: function(obj) {
                var str = [];
                for(var p in obj)
                str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                return str.join("&");
            }
        });
    };

    TIRAPI.printStudy = function(){
      return $http({
            method: 'POST',
            data: JSON.stringify(TIRAPI.study), 
            url: '/cgi-bin/tir/print',
            responseType: 'arraybuffer'
            //headers: {'Content-Type': 'application/x-www-form-urlencoded'}
        });
    };


    TIRAPI.saveTemplate = function(template){
      TIRAPI.template.Template = template;
      return $http({
            method: 'POST',
            data: TIRAPI.template, 
            url: '/cgi-bin/tir/template',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            // without transformRequest posted data is json
            transformRequest: function(obj) {
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

    TIRAPI.getTemplate = function(idtemplate) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/template?IdTemplate=' + idtemplate
      });
    }

    TIRAPI.newTemplate = function() {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/template/new'
      });
    }

    TIRAPI.getPatient = function(idpatient) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/patient?IdPatient=' + idpatient
      });
    }

    return TIRAPI;
  });
