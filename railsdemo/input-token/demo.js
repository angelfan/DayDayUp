$(document).on('page:change', function () {
  $(".ids_input_token").each(function () {
    $(this).tokenInput(
      'home_products/work_names.json',
      {
        theme: "facebook",
        preventDuplicates: true,
        prePopulate: [
          {id: $(this).data("id"), name: $(this).data("name")}
        ],
        resultsFormatter: function (item) {
          return "<li>" + "<img src='" + item.remote_cover_image_url + "' height='25px' width='25px' />" + "<div style='display: inline-block; padding-left: 10px;'><div class='work_name'>" + item.name + "</div><div class='work_model'>" + item.model + "</div></div></li>"
        },
        tokenFormatter: function (item) {
          return "<li><p>" + item.name + "</p></li>"
        },
        onAdd: function (item) {
          if ($(this).tokenInput("get").length > 1) {
            $(this).tokenInput("remove", $(this).tokenInput("get")[0]);
          }
        }
      }
    );
  })
});