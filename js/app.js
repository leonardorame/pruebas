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
  'TIRApp.controllers.insertupdatetpl',
  'ngRoute',
  'ngCookies',
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
    $rootScope.$on("$routeChangeStart", function (event, next, current) {
      if(typeof TIRAPIservice.user() === 'undefined') {
        $location.path('/login');
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
            restrict: 'CE',
            link: function (scope, elm, attr, model) {
                CKEDITOR.env.isCompatible = true;
                var isReady = false;
                var data = [];
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
                              scope.save();
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
                var editorConfig = scope.getEditorConfig( elm[0] );
                var ck = CKEDITOR.replace( elm[0], editorConfig);
                var edt = ck;
                edt.on('contentDom', function(){
                    edt.editable().attachListener(edt.document, 'keyup', function(event) {
                       scope.keyUp(event); 
                    });
                    edt.editable().attachListener(edt.document, 'keydown', function(event) {
                       scope.keyDown(event); 
                    });
                    edt.editable().attachListener(edt.document, 'key', function(event) {
                       scope.keyPress(event); 
                    });
                });
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
	when("/logoff", {templateUrl: "partials/login.html", controller: "logoffController"}).
	when("/templates", {templateUrl: "partials/templates.html", controller: "templatesController"}).
	when("/patients", {templateUrl: "partials/patients.html", controller: "patientsController"}).
	when("/users", {templateUrl: "partials/users.html", controller: "usersController"}).
	when("/", {redirectTo: '/turnos'}).
	when("/turnos", {templateUrl: "partials/turnos.html", controller: "turnosController"}).
	when("/turnos/:id", {templateUrl: "partials/turno.html", controller: "turnoController"}).
	otherwise({redirectTo: '/login'});
}]);


angular.module('TIRApp').directive('onBlurChange', function ($parse) {
  return function (scope, element, attr) {
    var fn = $parse(attr['onBlurChange']);
    var hasChanged = false;

    element.bind("keypress", function(event) {
      if(event.keyCode === 13) {
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
