angular.module('TIRApp.controllers.logoff', []).
  controller('logoffController', function($scope, $location, $cookieStore) {
      $cookieStore.remove('user_');
      $location.path('/login');
});
