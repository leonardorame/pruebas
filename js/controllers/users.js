angular.module('TIRApp.controllers.users', []).
    
  controller('usersTableController', function($scope, $location, $modalInstance, TIRAPIservice) {
    $scope.users = [];

    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdUser',
        value: 'IdUser',
        width: '50px;'
    },
    {
        title: 'Nombre',
        value: 'UserName'
    },
    {
        title: 'Profile',
        value: 'UserGroup'
    }];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id'
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getUsers($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.users = response.data.data;
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

    $scope.ok = function(){
        $modalInstance.close($scope.user);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        

    $scope.go = function(user){
        TIRAPIservice.getUser(user.IdUser).success(
            function(data){
                $scope.user = data;
                $scope.currentuser = data;
            }
        );
    };
  }).

  /* Users controller */
  controller('usersController', function($filter, $scope, $location, TIRAPIservice, $modal) {
    $scope.users = [];
    $scope.TIRAPIservice = TIRAPIservice;
    $scope.totalPages = 0;
    $scope.itemCount = 0;
    $scope.headers = [
    {
        title: 'IdUser',
        value: 'IdUser',
        width: '50px;'
    },
    {
        title: 'IdUserGroup',
        value: 'IdUserGroup',
        width: '50px;'
    },
    {
        title: 'Nombre',
        value: 'UserName'
    },
    {
        title: 'Profile',
        value: 'UserGroup'
    }];
    //default criteria that will be sent to the server
    $scope.filterCriteria = {
        pageNumber: 1,
        sortDir: 'asc',
        sortedBy: 'id'
    };

    $scope.alert = undefined;
    $scope.closeAlert = function(){
      $scope.alert = undefined;
    };
    //The function that is responsible of fetching the result from the server and setting the grid to the new result
    $scope.fetchResult = function () {
    return TIRAPIservice.getUsers($scope.filterCriteria).
        then(function(response){
          // success handler
          $scope.users = response.data.data;
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
    // depending on user object is not undefined
    $scope.isShown = function(user){
        return user;
    };

    $scope.newUser = function(){
        TIRAPIservice.newUser().
            success(function(data, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Usuario creado exitosamente!'};
                $scope.fetchResult();
                $scope.go(data);
            }).
            error(function(data, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar crear Usuario. COD: ' + status};
            });
    }

    // simplemente selecciona la fila 
    // actual al hacer click
    $scope.selectUser = function(user){
        $scope.user = user;
        $scope.currentuser = user;
    };

    // abre el dialogo de edición de datos
    // de usuario
    $scope.go = function(user){
        TIRAPIservice.getUser(user.IdUser).success(
            function(data){
                $scope.alert = undefined;
                $scope.currentuser = data;
                $scope.user = data;
                // se abre el dialogo
                $modal.open({
                    controller: 'userDialogController',
                    templateUrl: 'partials/userDialog.html',
                    resolve: {
                        user: function(){
                            return $scope.user;
                        }
                    }
                }).result.then(function(user){
                });
            }
        );
    };

  }).

  controller('userDialogController', function($filter, $scope, $location, $modalInstance, TIRAPIservice, user) {
    $scope.user = user;
    $scope.ok = function(){
        $modalInstance.close($scope.user);
    };        

    $scope.cancel = function(){
        $modalInstance.dismiss('cancel');
    };        
  });
