angular.module('TIRApp', [
  'TIRApp.services',
  'TIRApp.controllers',
  'ngRoute'
]).

run(['TIRAPIservice', '$rootScope', '$location', function(TIRAPIservice, $rootScope, $location){
    $rootScope.$on( "$routeChangeStart", function(event, next, current){
        if(!TIRAPIservice.user.id){
            TIRAPIservice.retrieveUserInfo().
                success(function(data){
                    TIRAPIservice.user.id = data.id;
                    TIRAPIservice.user.name = data.name;
                    TIRAPIservice.user.fullname = data.fullname;
                    TIRAPIservice.user.profile = data.profile;
                    TIRAPIservice.user.idprofessional = data.idprofessional;
                    console.log(TIRAPIservice.user);
                    //$location.path('/turnos');
                    //$route.reload();
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
            restrict: 'C',
            link: function (scope, elm, attr, model) {
                var isReady = false;
                var data = [];
                CKEDITOR.editorConfig = function( config ) {
                  config.width = 600;
                  config.height = 700;
                  config.autoGrow_onStartup = false;
                };
                CKEDITOR.plugins.registered['save'] = {
                    init: function (editor) {
                       // Save Command
                       var command = editor.addCommand('save',
                       {
                            modes: { wysiwyg: 1, source: 1 },
                            exec: function (editor) { // Add here custom function for the save button
                              var study = {};
                              study.Report = editor.getData();
                              study.IdStudy = $routeParams.id;
                              study.IdProfessional = TIRAPIservice.user.idprofessional;
                              $.ajax({
                                type: 'POST', 
                                url: '/cgi-bin/tir/study',
                                data: study,
                                success: function(data, textStatus, request){
                                  // se inserta el texto
                                  alert("Documento almacenado correctamente");
                                },
                                error: function(req, status, error){
                                  alert(error);
                                }
                              })
                            }
                       });
                       editor.ui.addButton('Save', { label: 'Save', command: 'save', toolbar: 'document, 1' });
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
	when("/turnos", {templateUrl: "partials/turnos.html", controller: "turnosController"}).
	when("/turnos/:id", {templateUrl: "partials/turno.html", controller: "turnoController"}).
	otherwise({redirectTo: '/login'});
}]);

angular.module('TIRApp').directive('onBlurChange', function ($parse) {
  return function (scope, element, attr) {
    var fn = $parse(attr['onBlurChange']);
    var hasChanged = false;
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

angular.module('TIRApp').directive('onEnterBlur', function() {
  return function(scope, element, attrs) {
    element.bind("keydown keypress", function(event) {
      if(event.which === 13) {
        element.blur();
        event.preventDefault();
      }
    });
  };
});
