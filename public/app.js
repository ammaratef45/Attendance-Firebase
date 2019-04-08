
function getUiConfig() {
    return {
      'callbacks': {
        'signInSuccessWithAuthResult': function(authResult, redirectUrl) {
          if (authResult.user) {
            handleSignedInUser(authResult.user);
          }
          return false;
        }
      },
      'signInFlow': 'popup',
      'signInOptions': [
        {
          provider: firebase.auth.GoogleAuthProvider.PROVIDER_ID,
          authMethod: 'https://accounts.google.com',
          clientId: CLIENT_ID
        }
      ],
      'tosUrl': 'https://www.google.com',
      'privacyPolicyUrl': 'https://www.google.com',
      'credentialHelper': firebaseui.auth.CredentialHelper.GOOGLE_YOLO
    };
  }

  function loadSessions(token) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        loadClasses(JSON.parse(this.responseText).data.classes)
      }
    };
    const url = "https://attendance-app-api.herokuapp.com/getInfo";
    //const url = "http://127.0.0.1:3000/getInfo"; 
    xhttp.open("POST", url, true);
    xhttp.withCredentials = true;
    xhttp.setRequestHeader('x-token', token);
    xhttp.send();
  }

  function loadClasses(classes) {
    for(everyclass in classes) {
      let name = classes[everyclass].name;
      let id = name+"tog";
      let list_id = id + "list";
      let htmlText = "<input class=\"box\" id=\""+id+"\" type=\"checkbox\"/>";
      htmlText += "<label for=\""+id+"\" style=\"display:block;\">";
      htmlText += "<span style=\"display:inline-block;\">" + name + "</span>";
      htmlText += "</label>";
      htmlText += "<div id=\"" + list_id + "\">";
      htmlText += "<ul>";
      for(session in classes[everyclass].sessions) {
        let val = classes[everyclass].sessions[session].qrval;
        let json = JSON.parse(val);        
        let date = json["date"];
        htmlText += "<li>" + date + "</li>"
      }
      htmlText += "</ul>";
      htmlText += "</div>";
      document.getElementById('user-sessions').innerHTML += htmlText;
      let element = document.getElementById(id);
      element.style.display = "none";
      document.getElementById(list_id).style.display = "none";
    }
    addEventListners();
  }

  function addEventListners() {
    const elemens = document.getElementsByClassName('box');
    for(let i=0; i<elemens.length; i++) {
      elemens[i].addEventListener("change", function (event) {
        let clickedBox = event.target;
        if(clickedBox.checked) {
          document.getElementById(clickedBox.id+"list").style.display = "block";
        } else {
          document.getElementById(clickedBox.id+"list").style.display = "none";
        }
    });
    }
  }
  
  var ui = new firebaseui.auth.AuthUI(firebase.auth());
  ui.disableAutoSignIn();
  
  
  var handleSignedInUser = function(user) {
    document.getElementById('user-signed-in').style.display = 'block';
    document.getElementById('user-signed-out').style.display = 'none';
    document.getElementById('name').textContent = user.displayName;
    document.getElementById('email').textContent = user.email;
    document.getElementById('phone').textContent = user.phoneNumber;
    user.getIdToken().then(function(accessToken) {
      loadSessions(accessToken);
    });
    if (user.photoURL){
      var photoURL = user.photoURL;
      if ((photoURL.indexOf('googleusercontent.com') != -1) ||
          (photoURL.indexOf('ggpht.com') != -1)) {
        photoURL = photoURL + '?sz=' +
            document.getElementById('photo').clientHeight;
      }
      document.getElementById('photo').src = photoURL;
      document.getElementById('photo').style.display = 'block';
    } else {
      document.getElementById('photo').style.display = 'none';
    }
  };
  
  
  /**
   * Displays the UI for a signed out user.
   */
  var handleSignedOutUser = function() {
    document.getElementById('user-signed-in').style.display = 'none';
    document.getElementById('user-signed-out').style.display = 'block';
    ui.start('#firebaseui-container', getUiConfig());
  };
  
  // Listen to change in auth state so it displays the correct UI for when
  // the user is signed in or not.
  firebase.auth().onAuthStateChanged(function(user) {
    document.getElementById('loading').style.display = 'none';
    document.getElementById('loaded').style.display = 'block';
    user ? handleSignedInUser(user) : handleSignedOutUser();
  });
  
  
  /**
   * Initializes the app.
   */
  var initApp = function() {
    document.getElementById('sign-out').addEventListener('click', function() {
      firebase.auth().signOut();
    });
  };
  
  window.addEventListener('load', initApp);