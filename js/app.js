angular.module('TIRApp', [
  'TIRApp.services',
  'TIRApp.controllers',
  'TIRApp.controllers.login',
  'TIRApp.controllers.templates',
  'TIRApp.controllers.patient',
  'TIRApp.controllers.turno',
  'TIRApp.controllers.users',
  'TIRApp.controllers.status',
  'TIRApp.controllers.studystatuses',
  'ngRoute',
  'ui.bootstrap'
], function($httpProvider) {
  // Use x-www-form-urlencoded Content-Type
  $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';
 
  /**
   * The workhorse; converts an object to x-www-form-urlencoded serialization.
   * @param {Object} obj
   * @return {String}
   */
  var param = function(obj) {
    var query = '', name, value, fullSubName, subName, subValue, innerObj, i;
      
    for(name in obj) {
      value = obj[name];
        
      if(value instanceof Array) {
        for(i=0; i<value.length; ++i) {
          subValue = value[i];
          fullSubName = name + '[' + i + ']';
          innerObj = {};
          innerObj[fullSubName] = subValue;
          query += param(innerObj) + '&';
        }
      }
      else if(value instanceof Object) {
        for(subName in value) {
          subValue = value[subName];
          fullSubName = name + '[' + subName + ']';
          innerObj = {};
          innerObj[fullSubName] = subValue;
          query += param(innerObj) + '&';
        }
      }
      else if(value !== undefined && value !== null)
        query += encodeURIComponent(name) + '=' + encodeURIComponent(value) + '&';
    }
      
    return query.length ? query.substr(0, query.length - 1) : query;
  };
 
  // Override $http service's default transformRequest
  $httpProvider.defaults.transformRequest = [function(data) {
    return angular.isObject(data) && String(data) !== '[object File]' ? param(data) : data;
  }];
}).
run(['TIRAPIservice', '$rootScope', '$location', function(TIRAPIservice, $rootScope, $location){
    $rootScope.$on( "$routeChangeSuccess", function(event, next, current){
        if(!TIRAPIservice.user.id){
            TIRAPIservice.retrieveUserInfo().
                success(function(data){
                    TIRAPIservice.user.id = data.id;
                    TIRAPIservice.user.name = data.name;
                    TIRAPIservice.user.fullname = data.fullname;
                    TIRAPIservice.user.profile = data.profile;
                    TIRAPIservice.user.idprofessional = data.idprofessional;
                    $rootScope.userName = data.fullname;
                }).
                error(function(data, status, headers, config){
                    $location.path('/login');
                });
        }
    });
}]).

/* directiva main-menu */
directive("mainMenu", function(){
    return {
        restrict: 'A',
        templateUrl: 'partials/menu.html',
        scope: true,
        transclude: false
    }
}).

directive('ckEditor', [function(){
        return {
            require: '?ngModel',
            //controller: 'turnoController',
            restrict: 'CE',
            link: function (scope, elm, attr, model) {
                var isReady = false;
                var data = [];
                CKEDITOR.editorConfig = function( config ) {
                  config.width = 600;
                  config.height = 700;
                  config.autoGrow_onStartup = false;
                };
                CKEDITOR.plugins.registered['templates'] = {
                    init: function (editor) {
                       // click template Command
                       var command = editor.addCommand('templates',
                       {
                            modes: { wysiwyg: 1, source: 1 },
                            exec: function (editor) { // Add here custom function for the save button
                              scope.selectTemplate();
                            }
                       });
                       editor.ui.addButton('Templates', { label: 'Templates', command: 'templates', toolbar: 'document, 2' });
                    }
                }
                CKEDITOR.plugins.registered['save'] = {
                    init: function (editor) {
                       // Save Command
                       var command = editor.addCommand('save',
                       {
                            modes: { wysiwyg: 1, source: 1 },
                            exec: function (editor) { // Add here custom function for the save button
                              scope.save(editor.getData());
                            }
                       });
                       editor.ui.addButton('Save', { label: 'Save', command: 'save', toolbar: 'document, 1' });
                    }
                }
                CKEDITOR.plugins.registered['print'] = {
                    init: function (editor) {
                       // Save Command
                       var command = editor.addCommand('print',
                       {
                            modes: { wysiwyg: 1, source: 1 },
                            exec: function (editor) { // Add here custom function for the save button
                              scope.print();
                            }
                       });
                       editor.ui.addButton('Print', { label: 'Print', command: 'print', toolbar: 'document, 5' });
                    }
                }
                var ck = CKEDITOR.replace( elm[0], {
                  toolbarGroups: [
                      { name: 'document',	   groups: [ 'mode', 'document' ] },			// Displays document group with its two subgroups.
                      { name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },			// Group's name will be used to create voice label.
                      { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
                    ]
                } );
                function setData(){
                    if(!data.length) {
                        return;
                    }

                    var d = data.splice(0, 1);
                    ck.setData(d[0] || '<span></span>', function() {
                        setData();
                        isReady = true;
                    });
                }
                
                ck.on('instanceReady', function(e) {
                    if(model) {
                        setData();
                    }
                });

                elm.bind('$destroy', function() {
                    ck.destroy(false);
                });

                if(model){
                    ck.on('change', function(){
                        scope.$apply(function(){
                            var data = ck.getData();
                            if(data == '<span></span>'){
                                data = null;
                            }
                            model.$setViewValue(data);
                        });
                    });
                    
                    model.$render = function(value) {
                        if (model.$viewValue === undefined) {
                            model.$setViewValue(null);
                            model.$viewValue = null;
                        }
                        data.push(model.$viewValue);
                        if(isReady) {
                            isReady = false;
                            setData();
                        }
                    }
                }
            }
        }
    }]).

config(['$routeProvider', function($routeProvider) {
  $routeProvider.
	when("/login", {templateUrl: "partials/login.html", controller: "loginController"}).
	when("/templates", {templateUrl: "partials/templates.html", controller: "templatesController"}).
	when("/patients", {templateUrl: "partials/patients.html", controller: "patientsController"}).
	when("/users", {templateUrl: "partials/users.html", controller: "usersController"}).
	when("/turnos", {templateUrl: "partials/turnos.html", controller: "turnosController"}).
	when("/turnos/:id", {templateUrl: "partials/turno.html", controller: "turnoController"}).
	otherwise({redirectTo: '/login'});
}]);


angular.module('TIRApp').directive('onBlurChange', function ($parse) {
  return function (scope, element, attr) {
    var fn = $parse(attr['onBlurChange']);
    var hasChanged = false;

    element.bind("keypress", function(event) {
      if(event.which === 13) {
        hasChanged = true;
        scope.$apply(function () {
          fn(scope, {$event: event});
        });
        event.preventDefault();
      }
    });

    element.on('change', function (event) {
      hasChanged = true;
    });
 
    element.on('blur', function (event) {
      if (hasChanged) {
        scope.$apply(function () {
          fn(scope, {$event: event});
        });
        hasChanged = false;
      }
    });
  };
});
