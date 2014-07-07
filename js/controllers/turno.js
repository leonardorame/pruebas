angular.module('TIRApp.controllers.turno', []).

  /* Turno controller */
  controller('turnoController', function($scope, $routeParams, TIRAPIservice, $modal) {
      var audioCtx = null;
      var recorder = null;
      var source = null;
      var analyser = null;
      $scope.study = TIRAPIservice.study;
      $scope.userName = TIRAPIservice.user.fullname;
      $scope.alert = undefined;
      TIRAPIservice.getStudy($routeParams.id).success(
            function(data){
                TIRAPIservice.study = data
                $scope.study = TIRAPIservice.study;
                $scope.alert = undefined;
            }
      );

      $scope.activate = function(study){
          TIRAPIservice.study.IdStatus = study.IdStatus;
      };

      $scope.closeAlert = function(){
        $scope.alert = undefined;
      };
            
      $scope.initAudio = function(){
         try {
             // webkit shim
             if(!audioCtx){
                 window.AudioContext = window.AudioContext || window.webkitAudioContext;
                 navigator.getUserMedia = ( navigator.getUserMedia ||
                     navigator.webkitGetUserMedia ||
                     navigator.mozGetUserMedia ||
                     navigator.msGetUserMedia);
                 window.URL = window.URL || window.webkitURL;
                 
                 audioCtx = new AudioContext;
                 navigator.getUserMedia({audio: true}, 
                    $scope.startUserMedia,
                    function(e) {
                    alert('No live audio input: ' + e);
                 });
             }
         } catch (e) {
             alert('No web audio support in this browser!');
         }
      }

      $scope.visualize = function (stream) {
          source = audioCtx.createMediaStreamSource(stream);
          analyser = audioCtx.createAnalyser();
          analyser.fftSize = 2048;
          var bufferLength = analyser.frequencyBinCount;
          var dataArray = new Uint8Array(bufferLength);

          source.connect(analyser);
          
          var canvas = document.getElementById('histograma');
          var canvasCtx = canvas.getContext("2d");
          WIDTH = canvas.width
          HEIGHT = canvas.height;

          draw()

          function draw() {
            requestAnimationFrame(draw);
            analyser.getByteTimeDomainData(dataArray);
            canvasCtx.fillStyle = 'rgb(200, 200, 200)';
            canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
            canvasCtx.lineWidth = 2;
            canvasCtx.strokeStyle = 'rgb(0, 0, 0)';
            canvasCtx.beginPath();
            var sliceWidth = WIDTH * 1.0 / bufferLength;
            var x = 0;
            for(var i = 0; i < bufferLength; i++) {
              var v = dataArray[i] / 128.0;
              var y = v * HEIGHT/2;
              if(i === 0) {
                canvasCtx.moveTo(x, y);
              } else {
                canvasCtx.lineTo(x, y);
              }
              x += sliceWidth;
            }
            canvasCtx.lineTo(canvas.width, canvas.height/2);
            canvasCtx.stroke();
          }
        }

      $scope.startUserMedia = function (stream) {
            recorder = new MediaRecorder(stream);
            recorder.ondataavailable = $scope.ondataavailable;
      }

      $scope.record = function (){
            if(recorder.state == "paused")
                recorder.resume();
            else
                recorder.start();
            $scope.visualize(recorder.stream);
      }

      $scope.ondataavailable = function (e) {
            var clipContainer = document.createElement('article');
            var clipLabel = document.createElement('p');
            var audio = document.createElement('audio');
            var deleteButton = document.createElement('button');

            clipContainer.classList.add('clip');
            audio.setAttribute('controls', '');
            deleteButton.innerHTML = "Delete";
            clipLabel.innerHTML = "asdasd";

            clipContainer.appendChild(audio);
            clipContainer.appendChild(clipLabel);
            clipContainer.appendChild(deleteButton);
            var soundClips = document.getElementById("soundClips");
            soundClips.appendChild(clipContainer);

            var audioURL = window.URL.createObjectURL(e.data);
            audio.src = audioURL;
      }

      $scope.startRecording = function(button){
        button.disabled = false;
        $scope.record();
      }

      $scope.pauseRecording = function(button) {
        recorder.pause();
        button.disabled = true;
        source.disconnect(analyser);
      }

      $scope.stopRecording = function(button) {
        recorder.stop();
        button.disabled = true;
        source.disconnect(analyser);

      }

      $scope.playbackRecorderAudio = function (recorder, context) {
        recorder.getBuffer(function (buffers) {
          var source = context.createBufferSource();
          source.buffer = context.createBuffer(1, buffers[0].length, 44100);
          source.buffer.getChannelData(0).set(buffers[0]);
          source.buffer.getChannelData(0).set(buffers[1]);
          source.connect(context.destination);
          source.noteOn(0);
        });
      }

      $scope.selectTemplate = function(){
            $modal.open({
                controller: 'templatesTableModel',
                templateUrl: 'partials/templatestable.html'
            }).result.then(function(template){
                if(template)
                    $scope.study.Report = template.Template;
            });
      };

      $scope.save = function(document) {
          TIRAPIservice.saveStudy(document).
            success(function(data, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Documento guardado exitosamente!'};
            }).
            error(function(data, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar guardar documento. COD: ' + status};
            })
      };

      $scope.print = function() {
          TIRAPIservice.printStudy().
            success(function(response, status, headers, config){
                $scope.alert = {type: 'success', msg: 'Documento impreso exitosamente!'};
                var file = new Blob([response], {type: 'application/pdf'});
                var fileURL = URL.createObjectURL(file);
                window.open(fileURL);
            }).
            error(function(response, status, headers, config){
                $scope.alert = {type: 'danger', msg: 'Error al intentar imprimit documento. COD: ' + status};
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
  });
