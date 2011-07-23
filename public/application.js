var map = null;

function initialize() {
  var myLatlng = new google.maps.LatLng(35.2596352,-95.58807988);
  var myOptions = {
    zoom: 8,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  setMarkers(map, users);
}


function recenter (lat, long) {
  var center = new google.maps.LatLng(lat, long);
  //map.setCenter(center);
  map.panTo(center);

  // Check to see if already at current zoom level that way
  // the panTo called above animates instead of "jumping" if
  // the user clicked is already in the viewable map
  var current_zoom = map.getZoom();

  if (current_zoom !== 12) {
    setTimeout(function() {
      map.setZoom(12);
    }, 500);
  }

}


function setMarkers(map, users) {

  var bound = new google.maps.LatLngBounds();

  for (var i = 0; i < users.length; i++) {
    var user = users[i];

    if (user.lat != null || user.lng != null) {
        var old = false;

      var unixtime = Math.round(new Date().getTime()/1000.0)
      var user_updated = Math.round(new Date(user.updated_at).getTime()/1000.0);

        // green = 3 hours, yellow = 12 hours, red = 24 hours, else don't show
        if ((unixtime - user_updated) < 10800) {
          var image = '/images/green.png';
        } else if ((unixtime - user_updated) < 43200) {
          var image = '/images/yellow.png';
        } else if ((unixtime - user_updated) <= 86400) {
          var image = '/images/red.png';
        } else if ((unixtime - user_updated) > 86400) {
          var image = null;
          old = true;
        }

        // set shadow

        if (!old) {

          var shadow = new google.maps.MarkerImage(image,
          new google.maps.Size(74, 78),
          new google.maps.Point(0,0),
          new google.maps.Point(37, 78));
            var shape = {
              coord: [1, 1, 1, 20, 18, 20, 18 , 1],
              type: 'poly'
          };

          // set avatar
          image = new google.maps.MarkerImage(user.avatar_url,
          // This marker is 20 pixels wide by 32 pixels tall.
          new google.maps.Size(48, 48),
          // The origin for this image is 0,0.
          new google.maps.Point(0,0),
          // The anchor for this image is the base of the flagpole at 0,32.
          new google.maps.Point(24, 68));


          var myLatLng = new google.maps.LatLng(user.lat, user.lng);
          var marker = new google.maps.Marker({
            position: myLatLng,
            map: map,
            shadow: shadow,
            icon: image,
            shape: shape,
            title: user.username,
            zIndex: i,
        });



        bound.extend(myLatLng);

      }
    }

  }

  map.fitBounds(bound);

}

  function loadScript() {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "http://maps.google.com/maps/api/js?sensor=false&callback=initialize";
    document.body.appendChild(script);
  }

  window.onload = loadScript;