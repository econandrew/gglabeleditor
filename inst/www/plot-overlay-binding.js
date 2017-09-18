// Put code in an Immediately Invoked Function Expression (IIFE).
// This isn't strictly necessary, but it's good JavaScript hygiene.
(function() {

// See http://rstudio.github.io/shiny/tutorial/#building-outputs for
// more information on creating output bindings.

// First create a generic output binding instance, then overwrite
// specific methods whose behavior we want to change.
var binding = new Shiny.OutputBinding();

binding.find = function(scope) {
  // For the given scope, return the set of elements that belong to
  // this binding.
  return $(scope).find(".editable-plot-overlay");
};

binding.renderValue = function(el, data) {
  // This function will be called every time we receive new output
  // values for a line chart from Shiny. The "el" argument is the
  // div for this particular chart.

  var $el = $(el);

  var plotId = $el[0].getAttribute("plot-id");
  var $plot = $('#'+plotId);
  var changeId = $el[0].getAttribute("data-change");

  //console.log("Render");
  //console.log(data);
  //console.log($el);

  var waitForPlotBinding = function (){
      console.log("wait")
      Shiny.shinyapp.$values[plotId] !== undefined ? updateOverlay() : setTimeout(waitForPlotBinding, 50);
  };
  waitForPlotBinding();

  //if (Shiny.shinyapp.$values[plotId] !== undefined) {
  function updateOverlay() {
    var plotOffset = $plot.position();
    //console.log({top: $plot.offsetTop, left: $plot.offsetLeft});
    $el.css({position: "absolute", top: plotOffset.top, left: plotOffset.left, height: $plot.height(), width: $plot.width() });

    $el.empty();

    var coordmap = Shiny.shinyapp.$values[plotId].coordmap;
    console.log(coordmap);

    data.forEach(function(label) {
      handleData = {
        x: label.x,
        y: label.y
      };
      console.log("handleData", handleData);

      handlePos = coordmap[0].scale(handleData);

      console.log("handlePos", handlePos);


      $('<div label-key="'+label.key+'"class="geom_label overlay" style="position: absolute; left: '+handlePos.x+'px; bottom: '+($plot.height()-handlePos.y)+'px;"></div>').draggable({
        containment: $plot.find("img"),
        start: function( event, ui ) {
        },
        stop: function( event, ui ) {
          Shiny.onInputChange(changeId, $.extend(coordmap[0].scaleInv(coordmap.mouseOffset({pageX: ui.offset.left, pageY: ui.offset.top + ui.helper[0].clientHeight})), {key: label.key}));
        }
      }).append('<div class="handle bottom-left"></div>').appendTo($el);
    });
  }
};

// Tell Shiny about our new output binding
Shiny.outputBindings.register(binding, "editablePlotOverlay");

})();
