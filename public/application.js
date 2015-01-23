$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_stays();
});

function player_hits(){
  $(document).on("click","form#hit_button input",function(){
    alert("player hit");  
    $.ajax({
      type: "POST",
      url: "/player/hit"
    }).done(function(msg){
      $("#game").replaceWith(msg)
    });


    return false;
  });
}

function player_stays(){
  $(document).on("click","form#stay_button input",function(){
    alert("player stay");  
    $.ajax({
      type: "POST",
      url: "/player/stay"
    }).done(function(msg){
      $("#game").replaceWith(msg)
    });


    return false;
  });
}

function dealer_stays(){
  $(document).on("click","form#dealer_stay_button input",function(){
    alert("dealer hit");  
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(msg){
      $("#game").replaceWith(msg)
    });


    return false;
  });
}