angular.module('TIRApp.controllers', ['ui.bootstrap', 'dialogs.main','pascalprecht.translate']).
    
    controller('GridCtrl', function ($scope, $location, TIRAPIservice) {
          $scope.totalPages = 0;
          $scope.itemCount = 0;
          $scope.headers = [
          {
            title: 'IdStudy',
            value: 'IdStudy',
            width: '50px;'
          },
          {
            title: 'Apellido',
            value: 'Patient_LastName',
            width: '300px;'
          },
          {
            title: 'Nombre',
            value: 'Patient_Nombre',
            width: '300px;'
          },
          {
            title: 'Fecha',
            value: 'StudyDate',
            width: '100px;'
          },
          {
            title: 'Estado',
            value: 'state'
          }];
         
          //Will make an ajax call to fill the drop down menu in the filter of the states
          //$scope.states = TIRAPIservice.getTurnos();
         
          //default criteria that will be sent to the server
          $scope.filterCriteria = {
            pageNumber: 1,
            sortDir: 'asc',
            sortedBy: 'id'
          };
         
          //The function that is responsible of fetching the result from the server and setting the grid to the new result
          $scope.fetchResult = function () {
            return TIRAPIservice.getTurnos($scope.filterCriteria).
                then(function(response){
                  // success handler
                  $scope.turnos = response.data.data;
                  $scope.totalPages = response.data.recordsTotal / 10; // page size = 10
                  $scope.itemCount = response.data.recordsTotal;
                },function(response){
                    // error handler
                    $location.path('/login');
                });
          };
         
          //called when navigate to another page in the pagination
          $scope.selectPage = function (page) {
            $scope.filterCriteria.pageNumber = page;
            $scope.fetchResult();
          };
         
          //Will be called when filtering the grid, will reset the page number to one
          $scope.filterResult = function () {
            $scope.filterCriteria.pageNumber = 1;
            $scope.fetchResult().then(function () {
              //The request fires correctly but sometimes the ui doesn't update, that's a fix
              $scope.filterCriteria.pageNumber = 1;
            });
          };
         
          //call back function that we passed to our custom directive sortBy, will be called when clicking on any field to sort
          $scope.onSort = function (sortedBy, sortDir) {
            $scope.filterCriteria.sortDir = sortDir;
            $scope.filterCriteria.sortedBy = sortedBy;
            $scope.filterCriteria.pageNumber = 1;
            $scope.fetchResult().then(function () {
              //The request fires correctly but sometimes the ui doesn't update, that's a fix
              $scope.filterCriteria.pageNumber = 1;
            });
          };
         
          //manually select a page to trigger an ajax request to populate the grid on page load
          $scope.selectPage(1);
        }).

  /* login controller */
  controller('loginController', function($scope, TIRAPIservice, $location) {
      $scope.$watch('loginForm', function(frm) {
        if(frm){
            frm.$setPristine();
            frm.username = "";
        }
      }, true);
  
      $scope.submit = function(){
        TIRAPIservice.login($scope.username, $scope.password).
          success(function(data, status, headers, config){
            TIRAPIservice.user.id = data.id;
            TIRAPIservice.user.name = data.name;
            TIRAPIservice.user.fullname = data.fullname;
            TIRAPIservice.user.profile = data.profile;
            TIRAPIservice.user.idprofessional = data.idprofessional;
            $location.path('/turnos');
          }).
          error(function(data, status, headers, config){
            console.log(status);
          });
        }
  }).

  /* Turno controller */
  controller('turnoController', function($scope, $routeParams, TIRAPIservice) {
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      TIRAPIservice.getStudy($routeParams.id).success(
            function(data){
                TIRAPIservice.study = data
                $scope.study = TIRAPIservice.study;
            }
      );

      $scope.activate = function(study){
          TIRAPIservice.study.IdStatus = study.IdStatus;
      };

      $scope.save = function(document) {
          console.log('on saveStudy');
          TIRAPIservice.saveStudy(document).
            success(function(data, status, headers, config){
                console.log('success');
            }).
            error(function(data, status, headers, config){
                console.log('error');
            })
      };
  }).

  /* Templates controller */
  controller('templatesController', function($scope, $location, TIRAPIservice, dialogs) {
    $scope.templates = [];
    $scope.userName = TIRAPIservice.user.fullname;

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdPlantilla',
        value: 'IdTemplate',
        width: '50px;'
    },
    {
        title: 'Código',
        value: 'Code'
    },
    {
        title: 'Nombre',
        value: 'Name'
    }];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id'
    };

    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getTemplates($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.templates = response.data.data;
          $scope.totalPages = response.data.recordsTotal / 10; // page size = 10
          $scope.itemCount = response.data.recordsTotal;
        },function(response){
            // error handler
            $location.path('/login');
        });
    };

    //called when navigate to another page in the pagination
    $scope.selectPage = function (page) {
        $scope.filterCriteria.pageNumber = page;
        $scope.fetchResult();
    };

    //Will be called when filtering the grid, will reset the page number to one
    $scope.filterResult = function () {
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //call back function that we passed to our custom directive sortBy, will be called when clicking on any field to sort
    $scope.onSort = function (sortedBy, sortDir) {
        $scope.filterCriteria.sortDir = sortDir;
        $scope.filterCriteria.sortedBy = sortedBy;
        $scope.filterCriteria.pageNumber = 1;
        $scope.fetchResult().then(function () {
          //The request fires correctly but sometimes the ui doesn't update, that's a fix
          $scope.filterCriteria.pageNumber = 1;
        });
    };

    //manually select a page to trigger an ajax request to populate the grid on page load
    $scope.selectPage(1);

    // displays the div containing the editor
    // depending on template object is not undefined
    $scope.isShown = function(template){
        return (template);
    };

    $scope.go = function(template){
        TIRAPIservice.getTemplate(template.IdTemplate).success(
            function(data){
                TIRAPIservice.template = data
                $scope.template = TIRAPIservice.template;
            }
        );
    };

    $scope.save = function(document) {
      TIRAPIservice.saveTemplate(document).
        success(function(data, status, headers, config){
            dialogs.error();
            console.log('success');
        }).
        error(function(data, status, headers, config){
            console.log('error');
        })
      };
  }).

  /* Turnos controller */
  controller('turnosController', function($scope, $location, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.fullname;

    $scope.go = function(study){
        TIRAPIservice.study = study;
        var url = '/turnos/' + study.IdStudy;
        $location.path(url);
    };
  }).

  config(['dialogsProvider','$translateProvider',function(dialogsProvider,$translateProvider){
    dialogsProvider.useBackdrop('static');
    dialogsProvider.useEscClose(true);
    dialogsProvider.useCopy(false);
    dialogsProvider.setSize('sm');

    $translateProvider.translations('es',{
        DIALOGS_ERROR: "Error",
        DIALOGS_ERROR_MSG: "Se ha producido un error desconocido.",
        DIALOGS_CLOSE: "Cerca",
        DIALOGS_PLEASE_WAIT: "Espere por favor",
        DIALOGS_PLEASE_WAIT_ELIPS: "Espere por favor...",
        DIALOGS_PLEASE_WAIT_MSG: "Esperando en la operacion para completar.",
        DIALOGS_PERCENT_COMPLETE: "% Completado",
        DIALOGS_NOTIFICATION: "Notificacion",
        DIALOGS_NOTIFICATION_MSG: "Notificacion de aplicacion Desconocido.",
        DIALOGS_CONFIRMATION: "Confirmacion",
        DIALOGS_CONFIRMATION_MSG: "Se requiere confirmacion.",
        DIALOGS_OK: "Bueno",
        DIALOGS_YES: "Si",
        DIALOGS_NO: "No"
    });

    $translateProvider.preferredLanguage('es');
    }])

    .run(['$templateCache',function($templateCache){
       $templateCache.put('/dialogs/custom.html','<div class="modal-header"><h4 class="modal-title"><span class="glyphicon glyphicon-star"></span> User\'s Name</h4></div><div class="modal-body"><ng-form name="nameDialog" novalidate role="form"><div class="form-group input-group-lg" ng-class="{true: \'has-error\'}[nameDialog.username.$dirty && nameDialog.username.$invalid]"><label class="control-label" for="course">Name:</label><input type="text" class="form-control" name="username" id="username" ng-model="user.name" ng-keyup="hitEnter($event)" required><span class="help-block">Enter your full name, first &amp; last.</span></div></ng-form></div><div class="modal-footer"><button type="button" class="btn btn-default" ng-click="cancel()">Cancel</button><button type="button" class="btn btn-primary" ng-click="save()" ng-disabled="(nameDialog.$dirty && nameDialog.$invalid) || nameDialog.$pristine">Save</button></div>');
       $templateCache.put('/dialogs/custom2.html','<div class="modal-header"><h4 class="modal-title"><span class="glyphicon glyphicon-star"></span> Custom Dialog 2</h4></div><div class="modal-body"><label class="control-label" for="customValue">Custom Value:</label><input type="text" class="form-control" id="customValue" ng-model="data.val" ng-keyup="hitEnter($event)"><span class="help-block">Using "dialogsProvider.useCopy(false)" in your applications config function will allow data passed to a custom dialog to retain its two-way binding with the scope of the calling controller.</span></div><div class="modal-footer"><button type="button" class="btn btn-default" ng-click="done()">Done</button></div>')
    }]); 

