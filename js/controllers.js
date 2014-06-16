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
            return TIRAPIservice.getTurnos($scope.filterCriteria).then(function (data) {
              console.log(data.data);
              $scope.customers = data.data.data;
              $scope.totalPages = 20;
              $scope.itemCount = 100;
              $scope.filterCriteria.pageNumber = 1;
            }, function () {
              $scope.customers = [];
              $scope.totalPages = 0;
              $scope.customersCount = 0;
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

  /* Turnos controller */
  controller('turnosController', function($scope, TIRAPIservice) {
    $scope.turnos = [];
    $scope.userName = TIRAPIservice.user.name;
    TIRAPIservice.getTurnos().success(function (response) {
        //Digging into the response to get the relevant data
    });
  });

