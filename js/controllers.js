angular.module('TIRApp.controllers', ['ui.bootstrap']).
    
    controller('GridCtrl', function ($scope, TIRAPIservice) {
          $scope.totalPages = 0;
          $scope.itemCount = 0;
          $scope.headers = [
          {
            title: 'Id',
            value: 'id'
          },
          {
            title: 'Name',
            value: 'name'
          },
          {
            title: 'Email',
            value: 'email'
          },
          {
            title: 'City',
            value: 'city'
          },
          {
            title: 'State',
            value: 'state'
          }];
         
          //Will make an ajax call to fill the drop down menu in the filter of the states
          $scope.states = TIRAPIservice.getTurnos();
         
          //default criteria that will be sent to the server
          $scope.filterCriteria = {
            pageNumber: 1,
            sortDir: 'asc',
            sortedBy: 'id'
          };
         
          //The function that is responsible of fetching the result from the server and setting the grid to the new result
          $scope.fetchResult = function () {
            console.log($scope.filterCriteria);
            return TIRAPIservice.getTurnos($scope.filterCriteria).then(function (data) {
              console.log(data.data);
              $scope.turnos = data.data.data;
              $scope.totalPages = data.data.recordsTotal / 10; // page size = 10
              $scope.itemCount = data.data.recordsTotal;
            }, function () {
              $scope.turnos = [];
              $scope.totalPages = 0;
              $scope.itemCount = 0;
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
      $scope.submit = function(){
        TIRAPIservice.login($scope.username, $scope.password).
          success(function(data, status, headers, config){
            TIRAPIservice.user.name = data.fullname
            $location.path('/turnos');
          }).
          error(function(data, status, headers, config){
            console.log(status);
          });
        }
  }).

  /* Turno controller */
  controller('turnoController', function($scope, $routeParams, TIRAPIservice) {
    $scope.userName = TIRAPIservice.user.name;
    CKEDITOR.editorConfig = function( config ) {
      config.width = 600;
      config.height = 700;
      config.autoGrow_onStartup = false;
    };
    var editor = CKEDITOR.replace( 'editor2', {
      toolbarGroups: [
          { name: 'document',	   groups: [ 'mode', 'document' ] },			// Displays document group with its two subgroups.
          { name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },			// Group's name will be used to create voice label.
          { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
        ]
    } );
    CKEDITOR.on('instanceReady', function(evt){
      evt.editor.setData('Texto del estudio ID:' + $routeParams.id);
      //resize(evt.editor);
    });
  }).

  /* Turnos controller */
  controller('turnosController', function($scope, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.name;
    TIRAPIservice.getTurnos().success(function (response) {
        //Digging into the response to get the relevant data
    });
  });

