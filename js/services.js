angular.module('TIRApp.services', [])
  .factory('TIRAPIservice', function($http) {
    var TIRAPI = {};
    TIRAPI.user = {};
    TIRAPI.study = {};
    TIRAPI.template = {};

    TIRAPI.studiesDefaultFilters = {
      pageNumber: 1,
      sortDir: 'asc',
      sortedBy: 'id',
      UserName: TIRAPI.user.name
    };

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
        data: filter,
        url: '/cgi-bin/tir/templates'
      });
    }

    TIRAPI.getStatuses = function(filter) {
      return $http({
        method: 'POST', 
        data: filter,
        url: '/cgi-bin/tir/statuses'
      });
    }

    TIRAPI.getUsers = function(filter) {
      return $http({
        method: 'POST', 
        data: filter,
        url: '/cgi-bin/tir/users'
      });
    }

    TIRAPI.getPatients = function(filter) {
      return $http({
        method: 'POST', 
        data: filter,
        url: '/cgi-bin/tir/patients'
      });
    }

    TIRAPI.getStudyStatuses = function(filter) {
      return $http({
        method: 'POST', 
        data: filter,
        url: '/cgi-bin/tir/studystatuses'
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

    TIRAPI.getStudy = function(idstudyprocedure) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/study?rnd=' + new Date().getTime() + '&IdStudyProcedure=' + idstudyprocedure
      });
    }

    TIRAPI.getTemplate = function(idtemplate) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/template?rnd=' + new Date().getTime() + '&IdTemplate=' + idtemplate
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
        url: '/cgi-bin/tir/patient?rnd=' + new Date().getTime() + '&IdPatient=' + idpatient
      });
    }

    TIRAPI.getUser = function(iduser) {
      return $http({
        method: 'GET', 
        url: '/cgi-bin/tir/users/' + iduser
      });
    }

    TIRAPI.assignStudiesToUser = function(studies, user) {
      var assignTo = {
        "studies": studies,
        "user": user
      };
      return $http({
            method: 'POST',
            data: JSON.stringify(assignTo), 
            url: '/cgi-bin/tir/assignto',
        });
    }

    TIRAPI.changeStatus = function(studies, status) {
      var changestatus = {
        "studies": studies,
        "status": status
      };
      return $http({
            method: 'POST',
            data: JSON.stringify(changestatus), 
            url: '/cgi-bin/tir/changestatus',
        });
    }

    return TIRAPI;
  });
