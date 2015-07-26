angular.module('TIRApp.controllers.stats', []).
  controller('statsController', function($scope, TIRAPIservice, $http, $cookieStore) {
    $scope.TIRAPIservice = TIRAPIservice;
    $scope.colors = [
        '#F7464A',
        '#46BFBD',
        '#FDB45C',
        '#949FB1'
    ]

    $scope.transparentColors = [
        'rgba(220,220,220,0.4)',
        'rgba(151,187,205,0.4)'
    ]

    // ----- Chart 1 ----
    $scope.chart_1 = {
      labels: [],
      datasets: [
        {
          label: 'CR',
          fillColor: $scope.colors[0],
          highlightStroke: $scope.colors[0],
          data: []
        },
        {
          label: 'CT',
          fillColor: $scope.colors[1],
          highlightStroke: $scope.colors[1],
          data: []
        },
        {
          label: 'MR',
          fillColor: $scope.colors[2],
          highlightStroke: $scope.colors[2],
          data: []
        },
        {
          label: 'US',
          fillColor: $scope.colors[3],
          highlightStroke: $scope.colors[3],
          data: []
        }

      ]
    };

    $scope.chart_1.options =  {
      maintainAspectRatio: true,
      responsive: true,
      scaleShowGridLines : true,
      scaleGridLineColor : "rgba(0,0,0,.05)",
      scaleGridLineWidth : 1,
      bezierCurve : true,
      bezierCurveTension : 0.4,
      pointDot : true,
      pointDotRadius : 4,
      pointDotStrokeWidth : 1,
      pointHitDetectionRadius : 20,
      datasetFill : true,
      legendTemplate : '<div class="tc-chart-js-legend" style="display: inline-block; height: 24px;"><% for (var i=0; i<datasets.length; i++){%><div style="float: left; width: 20px; height: 20px; margin-right: 4px; background-color:<%=datasets[i].fillColor%>"></div><div style="float: left; width: 50px; text-align: left;"><%=datasets[i].label%></div><%}%></div>'
    };

    $http({
            method: 'GET',
            url: '/cgi-bin/tir/stats/byModalityLast12Months',
            headers: {"Content-Type": 'application/json; charset=UTF-8'}
        }).error( function(data, status, headers, config) {
          //console.log('error');
        }).success( function(all, status, headers, config) {
            var studiesbymodality = all;
            for(var i = 0; i < studiesbymodality.length; i++) {
                $scope.chart_1.labels.push(studiesbymodality[i].Year + '/' + studiesbymodality[i].Month);
            };
            for(i = 0; i < studiesbymodality.length; i++) {
                $scope.chart_1.datasets[0].data.push(studiesbymodality[i].CR);
                $scope.chart_1.datasets[1].data.push(studiesbymodality[i].CT);
                $scope.chart_1.datasets[2].data.push(studiesbymodality[i].MR);
                $scope.chart_1.datasets[3].data.push(studiesbymodality[i].US);
            };
     }); 

    // ----- Chart 2 ----
    $scope.chart_2 = [];

    $http({
            method: 'GET',
            url: '/cgi-bin/tir/stats/globalByModality',
            headers: {"Content-Type": 'application/json; charset=UTF-8'}
        }).error( function(data, status, headers, config) {
          //console.log('error');
        }).success( function(data, status, headers, config) {
            for(i = 0; i < data.length; i++) {
                var dataset = {
                    color: $scope.colors[i],
                    label: data[i].modality,
                    value: data[i].round
                }
                $scope.chart_2.push(dataset);
            };
     }); 

    $scope.chart_2.options = {
      maintainAspectRatio: true,
      responsive: true,
      segmentShowStroke : true,
      segmentStrokeColor : '#fff',
      segmentStrokeWidth : 2,
      percentageInnerCutout : 0, // This is 0 for Pie charts
      animationSteps : 50,
      animationEasing : 'easeOutBounce',
      animateRotate : true,
      animateScale : false,
      legendTemplate : '<ul class="tc-chart-js-legend"><% for (var i=0; i<segments.length; i++){%><li><span style="background-color:<%=segments[i].fillColor%>"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>'
    }

    // ----- Chart 3 ----
    $scope.chart_3 = {
      labels: [],
      datasets: [
        {
          fillColor: $scope.transparentColors[1],
          strokeColor: $scope.transparentColors[0],
          data: []
        }
      ]
    };

    $scope.chart_3.options =  {
      maintainAspectRatio: false,
      responsive: true,
      scaleShowGridLines : true,
      scaleGridLineColor : "rgba(255,255,255,.1)",
      scaleGridLineWidth : 1,
      bezierCurve : true,
      bezierCurveTension : 0.4,
      pointDot : true,
      pointDotRadius : 4,
      pointDotStrokeWidth : 1,
      pointHitDetectionRadius : 20,
      datasetFill : true,
      legendTemplate : '<div class="tc-chart-js-legend" style="display: inline-block; height: 24px;"><% for (var i=0; i<datasets.length; i++){%><div style="float: left; width: 20px; height: 20px; margin-right: 4px; background-color:<%=datasets[i].fillColor%>"></div><div style="float: left; width: 50px; text-align: left;"><%=datasets[i].label%></div><%}%></div>'
    };

    $http({
            method: 'GET',
            url: '/cgi-bin/tir/stats/totalByMonth',
            headers: {"Content-Type": 'application/json; charset=UTF-8'}
        }).error( function(data, status, headers, config) {
          //console.log('error');
        }).success( function(data, status, headers, config) {
            for(var i = 0; i < data.length; i++) {
                $scope.chart_3.labels.push(data[i].Year + '/' + data[i].Month);
            };
            for(i = 0; i < data.length; i++) {
                $scope.chart_3.datasets[0].data.push(data[i].count);
            };
     }); 

})
