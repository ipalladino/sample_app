var car_models = [];
        
$('#ferrari_year_id').live('change', function(){
  $.ajax({
    url: "/ferraris/ferraris/year_selection",
    type: "GET",
    data: {'year' : $('#ferrari_year_id option:selected').val() }
  })
});


$(function() {
  if(App.page != undefined){ 
  if(App.page=="ferraris"){
  console.log("PAGE: "+App.page);
  $("#year-fr").on("focus", function(e) {
      if(e.currentTarget.value == "Year Fr")
        e.currentTarget.value = "";
  })
  $("#year-fr").on("blur", function(e) {
      if(e.currentTarget.value == "") {
          e.currentTarget.value = "Year Fr";
          $("#yrfr_id").val("");
      }
        
  })

  $("#year-to").on("focus", function(e) {
      if(e.currentTarget.value == "Year To")
          e.currentTarget.value = "";
  })
  $("#year-to").on("blur", function(e) {
      if(e.currentTarget.value == "") {
        e.currentTarget.value = "Year To";
        $("#yrto_id").val("");
      }
  })

  //model
  $("#model").on("focus", function(e) {
      if(e.currentTarget.value == "Model")
        e.currentTarget.value = "";
  })
  $("#model").on("blur", function(e) {
      if(e.currentTarget.value == "")
        e.currentTarget.value = "Model";
  })
  //PRICE
  $("#prce_fr").on("focus", function(e) {
      if(e.currentTarget.value == "Price Fr")
          e.currentTarget.value = "";
  })
  $("#prce_fr").on("blur", function(e) {
        if(e.currentTarget.value == "")
            e.currentTarget.value = "Price Fr";
  })
  $("#prce_to").on("focus", function(e) {
      if(e.currentTarget.value == "Price To")
          e.currentTarget.value = "";
  })
  $("#prce_to").on("blur", function(e) {
      if(e.currentTarget.value == "")
          e.currentTarget.value = "Price To";
  })

  //KEYWORDS
  $("#keywords").on("focus", function(e) {
        if(e.currentTarget.value == "Keywords")
            e.currentTarget.value = "";
  })
  $("#keywords").on("blur", function(e) {
          if(e.currentTarget.value == "")
              e.currentTarget.value = "Keywords";
  })

  $("#dropdown-models").on("click", function(){
      $("#model").autocomplete("search", "");
  });

  $("#year-fr").autocomplete({
      /* snip */
      source: years,
      select: function(event, ui) {
          event.preventDefault();
          $("#year-fr").val(ui.item.label);
          $("#yrfr_id").val(ui.item.value);
      },
      focus: function(event, ui) {
          event.preventDefault();
          $("#year-fr").val(ui.item.label);
      },
      close : function(event, ui) {
          event.preventDefault();
          var yrfr = $("#year-fr").val();
          for(i=0;i<years.length;i++) {
              if(years[i].label == yrfr) {
                  $("#yrfr_id").val(years[i].value);
                  break;
              }
              $("#yrfr_id").val("");
          }
      }
  });
  
  $("#year-to").autocomplete({
      /* snip */
      source: years,
      select: function(event, ui) {
          event.preventDefault();
          $("#year-to").val(ui.item.label);
          $("#yrto_id").val(ui.item.value);
      },
      focus: function(event, ui) {
          event.preventDefault();
          $("#year-to").val(ui.item.label);
      },
      close : function(event, ui) {
          event.preventDefault();
          var yrfr = $("#year-to").val();
          for(i=0;i<years.length;i++) {
              if(years[i].label == yrfr) {
                  $("#yrto_id").val(years[i].value);
                  break;
              }
              $("#yrto_id").val("");
          }
      }
  });

  var checkAndFilterModels = function(e) {
      var syea_fr = $("#year-fr").attr("value"),
          syea_to = $("#year-to").attr("value");

      var year_fr = Number($("#year-fr").attr("value")),
          year_to = Number($("#year-to").attr("value"));

      var blank_fr = (syea_fr == "" || syea_fr == "Year Fr")? true : false;
      var blank_to = (syea_to == "" || syea_to == "Year To")? true : false;

      if((year_fr >= Number(years[0].label) && year_fr <= year_to && year_to <= Number(years[years.length-1].label)) ||
          ((blank_fr && !blank_to) && year_to <= Number(years[years.length-1].label)) ||
          ((blank_to && !blank_fr) && year_fr >= Number(years[0].label))
      ) {
          $("#errorMessage").css("display", "none");
          e.preventDefault();
          $.ajax({
            type: "POST",
            url: "/filter_car_models",
            data: { year_fr: $("#year-fr").attr("value"), year_to: $("#year-to").attr("value") }
          })
            .done(function(response) {
                car_models = response;
                $("#model").autocomplete({
                    /* snip */
                        minLength: 0,
                        source: response,
                        select: function(event, ui) {
                            event.preventDefault();
                            $("#model").val(ui.item.label);
                            $("#modl_id").val(ui.item.value);
                        },
                        focus: function(event, ui) {
                            event.preventDefault();
                            $("#model").val(ui.item.label);
                        },
                        close: function(event, ui) {
                            event.preventDefault();
                            var yrfr = $("#model").val();
                            for(i=0;i<car_models.length;i++) {
                                if(car_models[i].label == yrfr) {
                                    $("#modl_id").val(car_models[i].value);
                                    break;
                                }
                                $("#modl_id").val("");
                            }
                        }
                });
          });
      } else {
          $("#errorMessage").css("display", "block");
      }
  }

  $("#year-fr").on("blur", checkAndFilterModels);
  $("#year-to").on("blur", checkAndFilterModels);
  $("#submit").on("click", function() {
      console.log("Submit");
      var model = $("#modl_id").val().trim();
      if(model == "" || model == "Model") {
          model = "";
      }
      price_to = ($("#prce_to").val() != "Price To")? $("#prce_to").val() : price_to = "";
      price_fr = ($("#prce_fr").val() != "Price Fr")? $("#prce_fr").val() : price_fr = "";
      yrfr_id = $("#yrfr_id").val();
      yrto_id = $("#yrto_id").val();
      
      App.carsColl.fetch({reset: true, data: {
          prce_to : price_to,
          prce_fr : price_fr,
          yrfr_id : yrfr_id,
          yrto_id : yrto_id,
          modl_id : model
      }})
  });
  
  
  App.ferrarisModel = new App.FerrarisModel();
  App.carsView = new App.CarsView({el : $('#ferraris-bb-list'), model: App.ferrarisModel});
  App.ferrarisModel.loadCollection();
  
}}
});