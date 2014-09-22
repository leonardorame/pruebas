angular.module('TIRApp.controllers.studystatuses', []).
    
  controller('studystatusTableController', function($scope, $location, $modalInstance, TIRAPIservice, study) {
    $scope.studystatuses = [];

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdStudyStatus',
        value: 'IdStudyStatus',
        width: '50px;'
    },
    {
        title: 'Fecha',
        value: 'Updated'
    },
    {
        title: 'UserName',
        value: 'UserName'
    },
    {
        title: 'IdStatus',
        value: 'IdStatus'
    },
    {
        title: 'Status',
        value: 'Status'
    }
    ];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id',
        IdStudy: study.IdStudy
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getStudyStatuses($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.studystatuses = response.data.data;
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

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        
});
