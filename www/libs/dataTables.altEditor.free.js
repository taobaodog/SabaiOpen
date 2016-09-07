/*! Datatables altEditor 1.0
*/

/**
 * @summary     altEditor
 * @description Lightweight editor for DataTables
 * @version     1.0
 * @file        dataTables.editor.lite.js
 * @author      kingkode (www.kingkode.com)
 * @contact     www.kingkode.com/contact
 * @copyright   Copyright 2016 Kingkode
 *
 * This source file is free software, available under the following license:
 *   MIT license - http://datatables.net/license/mit
 *
 * This source file is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the license files for details.
 *
 * For details please refer to: http://www.kingkode.com
 */

 /* Reworked edition
 This is a modified version of the altEditor 1.0

 New functionality:
  - Input validation.
  - Server communication with AJAX calls.

 Reworked:
  - Modal windows.
  - table rendering.
  - Add/Edit/Delete functions.
*/

(function( factory ){
  if ( typeof define === 'function' && define.amd ) {
        // AMD
        define( ['jquery', 'datatables.net'], function ( $ ) {
          return factory( $, window, document );
        } );
      }
      else if ( typeof exports === 'object' ) {
        // CommonJS
        module.exports = function (root, $) {
          if ( ! root ) {
            root = window;
          }

          if ( ! $ || ! $.fn.dataTable ) {
            $ = require('datatables.net')(root, $).$;
          }

          return factory( $, root, root.document );
        };
      }
      else {
        // Browser
        factory( jQuery, window, document );
      }
    }(function( $, window, document, undefined ) {
     'use strict';
     var DataTable = $.fn.dataTable;


     var _instance = 0;

   /** 
    * altEditor provides modal editing of records for Datatables
    *
    * @class altEditor
    * @constructor
    * @param {object} oTD DataTables settings object
    * @param {object} oConfig Configuration object for altEditor
    */
    var altEditor = function( dt, opts )
    {
     if ( ! DataTable.versionCheck || ! DataTable.versionCheck( '1.10.8' ) ) {
       throw( "Warning: altEditor requires DataTables 1.10.8 or greater");
     }

       // User and defaults configuration object
       this.c = $.extend( true, {},
         DataTable.defaults.altEditor,
         altEditor.defaults,
         opts
         );

       /**
        * @namespace Settings object which contains customisable information for altEditor instance
        */
        this.s = {
         /** @type {DataTable.Api} DataTables' API instance */
         dt: new DataTable.Api( dt ),

         /** @type {String} Unique namespace for events attached to the document */
         namespace: '.altEditor'+(_instance++)
       };


       /**
        * @namespace Common and useful DOM elements for the class instance
        */
        this.dom = {
         /** @type {jQuery} altEditor handle */
         modal: $('<div class="dt-altEditor-handle"/>'),
       };


       /* Constructor logic */
       this._constructor();
     }



     $.extend( altEditor.prototype, {
       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Constructor
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

       /**
        * Initialise the RowReorder instance
        *
        * @private
        */
        _constructor: function ()
        {
           // console.log('altEditor Enabled')
           var that = this;
           var dt = this.s.dt;
           
           this._setup();

           dt.on( 'destroy.altEditor', function () {
             dt.off( '.altEditor' );
             $(dt.table().body()).off( that.s.namespace );
             $(document.body).off( that.s.namespace );
           } );
         },

       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Private methods
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

       /**
        * Setup dom and bind button actions
        *
        * @private
        */
        _setup: function()
        {
         // console.log('Setup');

         var that = this;
         var dt = this.s.dt;

         // add modal
         $('body').append('\
          <div class="modal fade" id="altEditor-modal" tabindex="-1" role="dialog">\
          <div class="modal-dialog">\
          <div class="modal-content">\
          <div class="modal-header">\
          <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>\
          <h4 class="modal-title"></h4>\
          </div>\
          <div class="modal-body">\
          <p></p>\
          </div>\
          <div class="modal-footer">\
          <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>\
          <input type="submit" form="altEditor-form" class="btn btn-primary"></input>\
          </div>\
          </div>\
          </div>\
          </div>'
          );


         // add Edit Button
         if( this.s.dt.button('edit:name') )
         {
          this.s.dt.button('edit:name').action( function(e, dt, node, config) {
            var rows = dt.rows({
              selected: true
            }).count();

            that._openEditModal();
          });

          $(document).on('click', '#editRowBtn', function(e)
          {
            if(initValidation()){
              e.preventDefault();
              e.stopPropagation();
              that._editRowData();            
            }
          });

        }

         // add Delete Button
         if( this.s.dt.button('delete:name') )
         {
          this.s.dt.button('delete:name').action( function(e, dt, node, config) {
            var rows = dt.rows({
              selected: true
            }).count();

            that._openDeleteModal();
          });

          $(document).on('click', '#deleteRowBtn', function(e)
          {
            e.preventDefault();
            e.stopPropagation();
            that._deleteRow();
            $(this).prop('disabled', true);
          });
        }

         // add Add Button
         if( this.s.dt.button('add:name') )
         {
          this.s.dt.button('add:name').action( function(e, dt, node, config) {
            var rows = dt.rows({
              selected: true
            }).count();

            that._openAddModal();
          });

          $(document).on('click', '#addRowBtn', function(e)
          {
            if(initValidation()){
              e.preventDefault();
              e.stopPropagation();
              that._addRowData();               
            }
          });
        }

         // add Refresh button
         if( this.s.dt.button('refresh:name') )
         {
          this.s.dt.button('refresh:name').action( function(e, dt, node, config) {
            $.post('php/dhcp.php', {'act': 'get'})
              .done(function(res) {
                dt.ajax.reload();
                console.log("Datatable reloaded.")
               });
          });
        }
      },

       /**
        * Emit an event on the DataTable for listeners
        *
        * @param  {string} name Event name
        * @param  {array} args Event arguments
        * @private
        */
        _emitEvent: function ( name, args )
        {
         this.s.dt.iterator( 'table', function ( ctx, i ) {
           $(ctx.nTable).triggerHandler( name+'.dt', args );
         } );
       },

       /**
        * Open Edit Modal for selected row
        * 
        * @private
        */
        _openEditModal: function ( )
        {
         var that = this;
         var dt = this.s.dt;
         var columnDefs = [];

    //Adding column attributes to object.
    //Assuming that the first defined column is ID - Therefore skipping that
    //and starting at index 1, because we dont wanna be able to change the ID.
   for( var i = 1; i < dt.context[0].aoColumns.length; i++ )
   {
    columnDefs.push({ title: dt.context[0].aoColumns[i].sTitle,
      name: dt.context[0].aoColumns[i].data,
      type: dt.context[0].aoColumns[i].type,
      options: dt.context[0].aoColumns[i].options,
      msg: dt.context[0].aoColumns[i].errorMsg,
      hoverMsg: dt.context[0].aoColumns[i].hoverMsg,
      pattern: dt.context[0].aoColumns[i].pattern,
      special: dt.context[0].aoColumns[i].special
    });
  }
  var adata = dt.rows({
    selected: true
  });

          //Building edit-form
          var data = "";

          data += "<form name='altEditor-form' role='form'>";

          for(var j = 0; j < columnDefs.length; j++){
            data += "<div class='form-group'><div class='col-sm-5 col-md-5 col-lg-5 text-right' style='padding-top:4px;'><label for='" + columnDefs[j].title + "'>" + columnDefs[j].title + ":</label></div><div class='col-sm-6 col-md-6 col-lg-6'>";

            //Adding text-inputs and errorlabels
            if(columnDefs[j].type.includes("text")){
              data += "<input type='" + columnDefs[j].type + "' id='" + columnDefs[j].name + "'  pattern='" + columnDefs[j].pattern + "'  title='" + columnDefs[j].hoverMsg + "' name='" + columnDefs[j].title + "' placeholder='" + columnDefs[j].title + "' data-special='" + columnDefs[j].special + "' data-errorMsg='" + columnDefs[j].msg + "' style='overflow:hidden'  class='form-control  form-control-sm' value='" + adata.data()[0][columnDefs[j].name] + "'>";
              data += "<label id='" + columnDefs[j].name + "label" + "' class='errorLabel'></label>";
            }

            //Adding readonly-fields
            if(columnDefs[j].type.includes("readonly")){
              data += "<input type='text' readonly  id='" + columnDefs[j].title + "' name='" + columnDefs[j].title + "' placeholder='" + columnDefs[j].title + "' style='overflow:hidden'  class='form-control  form-control-sm' value='" + adata.data()[0][columnDefs[j].name] + "'>";
            }

            //Adding select-fields
            if(columnDefs[j].type.includes("select")){
              var options = "";
              for (var i = 0; i < columnDefs[j].options.length; i++) {
                //Assigning the selected value of the <selected> option
                if(adata.data()[0][columnDefs[j].name].includes(columnDefs[j].options[i])){
                  options += "<option value='" + columnDefs[j].options[i] + "'selected>" + columnDefs[j].options[i] + "</option>";
                }else{
                  options += "<option value='" + columnDefs[j].options[i] + "'>" + columnDefs[j].options[i] + "</option>";
                }
              }
              data += "<select class='form-control'>" + options + "</select>";
            } 
            data +="</div><div style='clear:both;'></div></div>";
          }

          data += "</form>";


          $('#altEditor-modal').on('show.bs.modal', function() {
            $('#altEditor-modal').find('.modal-title').html('Edit Record');
            $('#altEditor-modal').find('.modal-body').html(data);
            $('#altEditor-modal').find('.modal-footer').html("<button type='button' data-content='remove' class='btn btn-default' data-dismiss='modal'>Close</button>\
             <button type='button' data-content='remove' class='btn btn-primary' id='editRowBtn'>Submit</button>");

          });


          $('#altEditor-modal').modal('show');
          $('#altEditor-modal input[0]').focus();
        },

        _editRowData: function()
        {
          var that = this;
          var dt = this.s.dt;

        //Data from table columns
        var columnIds = [];
        //Data from input-fields
        var dataSet = [];
        //For JSON
        var aaData = [];
        var jsonDataArray = {};
        //complete JSONString for ajax call
        var comepleteJsonData = {};

        comepleteJsonData.data = aaData;

        var adata = dt.rows({
          selected: true
        });

        //Getting the IDs and Values of the tablerow
        for( var i = 0; i < dt.context[0].aoColumns.length; i++ )
        {
          columnIds.push({ id: dt.context[0].aoColumns[i].id,
            dataSet: adata.data()[0][dt.context[0].aoColumns[i].data]
          }); 
        }

        //Adding the ID & value of DT_RowId to the JsonArray
        jsonDataArray[columnIds[0].id] = columnIds[0].dataSet;

        //Getting the inputs from the edit-modal
        $('form[name="altEditor-form"] *').filter(':input').each(function( i )
        {
          dataSet.push( $(this).val() );
        });    

        //Adding the inputs from the edit-modal to JsonArray
        for(var i = 0; i < dataSet.length; i++){
          jsonDataArray[columnIds[i+1].id] = dataSet[i];
        }
        comepleteJsonData.data.push(jsonDataArray);


        //Calling AJAX with data, tableObject, command.
        updateJSON(comepleteJsonData, that, "editRow");   
  },


       /**
        * Open Delete Modal for selected row
        *
        * @private
        */
        _openDeleteModal: function ()
        {
         var that = this;
         var dt = this.s.dt;
         var columnDefs = [];

         //Adding attribute IDs and values to object
         for( var i = 1; i < dt.context[0].aoColumns.length; i++ )
         {
          columnDefs.push({ title: dt.context[0].aoColumns[i].sTitle,
            name: dt.context[0].aoColumns[i].data
          });
        }
        var adata = dt.rows({
          selected: true
        });

        //Building delete-modal
        var data = "";

        data += "<form name='altEditor-form' role='form'>";
        for(var j = 0; j < columnDefs.length; j++){
          data += "<div class='form-group'><label for='" + columnDefs[j].title + "'>" + columnDefs[j].title + " : </label><input  type='hidden'  id='" + columnDefs[j].title + "' name='" + columnDefs[j].title + "' placeholder='" + columnDefs[j].title + "' style='overflow:hidden'  class='form-control' value='" + adata.data()[0][columnDefs[j].name] + "' >" + adata.data()[0][columnDefs[j].name] + "</input></div>";
        }
        data += "</form>";

        $('#altEditor-modal').on('show.bs.modal', function() {
          $('#altEditor-modal').find('.modal-title').html('Delete Record');
          $('#altEditor-modal').find('.modal-body').html(data);
          $('#altEditor-modal').find('.modal-footer').html("<button type='button' data-content='remove' class='btn btn-default' data-dismiss='modal'>Close</button>\
           <button type='button'  data-content='remove' class='btn btn-danger' id='deleteRowBtn'>Delete</button>");
        });

        $('#altEditor-modal').modal('show');
        $('#altEditor-modal input[0]').focus();

      },

      _deleteRow: function( )
      {
       var that = this;
       var dt = this.s.dt;

        //For JSON
        var aaData = [];
        var jsonDataArray = {};
        //complete JSONString for ajax call
        var comepleteJsonData = {};

        comepleteJsonData.data = aaData;

        var adata = dt.rows({
          selected: true
        });

        //Getting the IDs and Values of the tablerow
        for( var i = 0; i < dt.context[0].aoColumns.length; i++ )
        {
          jsonDataArray[dt.context[0].aoColumns[i].id] = adata.data()[0][dt.context[0].aoColumns[i].data];
        }

        comepleteJsonData.data.push(jsonDataArray);

        //Calling AJAX with data, tableObject, command.
        updateJSON(comepleteJsonData, that, "deleteRow");

 },


       /**
        * Open Add Modal for selected row
        * 
        * @private
        */
        _openAddModal: function ( )
        {
         var that = this;
         var dt = this.s.dt;
         var columnDefs = [];

         //Adding column attributes to object.
         for( var i = 1; i < dt.context[0].aoColumns.length; i++ )
         {
          columnDefs.push({ title: dt.context[0].aoColumns[i].sTitle,
            name: dt.context[0].aoColumns[i].data,
            type: dt.context[0].aoColumns[i].type,
            options: dt.context[0].aoColumns[i].options,
            msg: dt.context[0].aoColumns[i].errorMsg,
            hoverMsg: dt.context[0].aoColumns[i].hoverMsg,
            pattern: dt.context[0].aoColumns[i].pattern,
            special: dt.context[0].aoColumns[i].special
          }); 
        }

        //Building add-form
        var data = "";
        data += "<form name='altEditor-form' role='form'>";
        for(var j = 0; j < columnDefs.length; j++){
         data += "<div class='form-group'><div class='col-sm-5 col-md-5 col-lg-5 text-right' style='padding-top:4px;'><label for='" + columnDefs[j].title + "'>" + columnDefs[j].title + ":</label></div><div class='col-sm-6 col-md-6 col-lg-6'>";

         //Adding text-inputs and errorlabels
         if(columnDefs[j].type.includes("text")){
          data += "<input type='" + columnDefs[j].type + "' id='" + columnDefs[j].name + "'  pattern='" + columnDefs[j].pattern + "'  title='" + columnDefs[j].hoverMsg + "' name='" + columnDefs[j].title + "' placeholder='" + columnDefs[j].title + "' data-special='" + columnDefs[j].special + "' data-errorMsg='" + columnDefs[j].msg + "' style='overflow:hidden'  class='form-control  form-control-sm' value=''>";
          data += "<label id='" + columnDefs[j].name + "label" + "' class='errorLabel'></label>";
        }

        //Adding readonly-fields
        if(columnDefs[j].type.includes("readonly")){
          data += "<input type='text' readonly  id='" + columnDefs[j].name + "' name='" + columnDefs[j].title + "' placeholder='" + columnDefs[j].title + "' style='overflow:hidden'  class='form-control  form-control-sm' value=''>";
        }

        //Adding select-fields
        if(columnDefs[j].type.includes("select")){
          var options = "";
          for (var i = 0; i < columnDefs[j].options.length; i++) {
            options += "<option value='" + columnDefs[j].options[i] + "'>" + columnDefs[j].options[i] + "</option>";
          }
          data += "<select class='form-control'>" + options + "</select>";
        } 
        data +="</div><div style='clear:both;'></div></div>";
      } 
      data += "</form>";

        $('#altEditor-modal').on('show.bs.modal', function() {
          $('#altEditor-modal').find('.modal-title').html('Add Record');
          $('#altEditor-modal').find('.modal-body').html(data);
          $('#altEditor-modal').find('.modal-footer').html("<button type='button' data-content='remove' class='btn btn-default' data-dismiss='modal'>Close</button>\
           <input type='submit'  data-content='remove' class='btn btn-primary' id='addRowBtn'></input>");
        });

        $('#altEditor-modal').modal('show');
        $('#altEditor-modal input[0]').focus();
      },

      _addRowData: function()
      {
        var that = this;
        var dt = this.s.dt;
        var rowID = dt.rows().data().length;
        //Containers with data from table columns
        var columnIds = [];
        //Data from input-fields.
        var inputDataSet = [];
        //For JSON
        var aaData = [];
        var jsonDataArray = {};
        //complete JSONString for ajax call
        var comepleteJsonData = {};

        comepleteJsonData.data = aaData;

        //Getting the IDs and Values of the tablerow
        for( var i = 0; i < dt.context[0].aoColumns.length; i++ ){
          columnIds.push({ id: dt.context[0].aoColumns[i].id });    
        }

        //Adding the ID & value(metadata) of the row to the JsonArray
        jsonDataArray[columnIds[0].id] = rowID;

        //Getting the inputs from the modal
        $('form[name="altEditor-form"] *').filter(':input').each(function( i ){

          inputDataSet.push( $(this).val() );
        });    

        //Adding the inputs from the modal to JsonArray
        for(var i = 0; i < inputDataSet.length; i++){
          jsonDataArray[columnIds[i+1].id] = inputDataSet[i];
        }
        comepleteJsonData.data.push(jsonDataArray);


        //Calling AJAX with data, tableObject, command.
        updateJSON(comepleteJsonData, that, "addRow");

        

},

_getExecutionLocationFolder: function() {
 var fileName = "dataTables.altEditor.js";
 var scriptList = $("script[src]");
 var jsFileObject = $.grep(scriptList, function(el) {

  if(el.src.indexOf(fileName) !== -1 )
  {
   return el;
 }
});
 var jsFilePath = jsFileObject[0].src;
 var jsFileDirectory = jsFilePath.substring(0, jsFilePath.lastIndexOf("/") + 1);
 return jsFileDirectory;
}
} );



   /**
    * altEditor version
    * 
    * @static
    * @type      String
    */
    altEditor.version = '1.0';


   /**
    * altEditor defaults
    * 
    * @namespace
    */
    altEditor.defaults = {
     /** @type {Boolean} Ask user what they want to do, even for a single option */
     alwaysAsk: false,

     /** @type {string|null} What will trigger a focus */
       focus: null, // focus, click, hover

       /** @type {column-selector} Columns to provide auto fill for */
       columns: '', // all

       /** @type {boolean|null} Update the cells after a drag */
       update: null, // false is editor given, true otherwise

       /** @type {DataTable.Editor} Editor instance for automatic submission */
       editor: null
     };


   /**
    * Classes used by altEditor that are configurable
    * 
    * @namespace
    */
    altEditor.classes = {
     /** @type {String} Class used by the selection button */
     btn: 'btn'
   };


   // Attach a listener to the document which listens for DataTables initialisation
   // events so we can automatically initialise
   $(document).on( 'preInit.dt.altEditor', function (e, settings, json) {
     if ( e.namespace !== 'dt' ) {
       return;
     }

     var init = settings.oInit.altEditor;
     var defaults = DataTable.defaults.altEditor;

     if ( init || defaults ) {
       var opts = $.extend( {}, init, defaults );

       if ( init !== false ) {
         new altEditor( settings, opts  );
       }
     }
   } );


   // Alias for access
   DataTable.altEditor = altEditor;
   return altEditor;
 }));

//Input validation for text-fields
var initValidation = function(){
  var isValid = false;
  var errorcount = 0;

  //Looping through all text fields
  $('form[name="altEditor-form"] *').filter(':text').each(function( i ){
    var errorLabel = "#"+ $(this).attr("id") + "label";

    //Inputvalidation for port range
    if($(this).attr("data-special") === "portRange"){
      var ports;
      if($(this).val().includes(":")){
        ports = $(this).val().split(":")

        var num1 = parseInt(ports[0])
        var num2 = parseInt(ports[1])

        if(num1 < num2){
          if(ports[0].match($(this).attr("pattern")) && ports[1].match($(this).attr("pattern"))){
            $(errorLabel).hide();
            $(errorLabel).empty();
          }else{
            $(errorLabel).html($(this).attr("data-errorMsg"));
            $(errorLabel).show();
            errorcount++
          }
        }else{
          $(errorLabel).html($(this).attr("data-errorMsg"));
          $(errorLabel).show();
          errorcount++
        }

      //If the port isnt a range
      }else if (!$(this).val().match($(this).attr("pattern"))){
           $(errorLabel).html($(this).attr("data-errorMsg"));
           $(errorLabel).show();
           errorcount++
         }else{

          //If no error
          $(errorLabel).hide();
          $(errorLabel).empty();
        }

    //All other text-inputs    
    }else if($(this).attr("data-special") != "portRange" && !$(this).context.checkValidity()){
        $(errorLabel).html($(this).attr("data-errorMsg"));
        $(errorLabel).show();
        errorcount++;

      //If no error
      }else{
        $(errorLabel).hide();
        $(errorLabel).empty();

      }
    });

if(errorcount == 0){
  isValid = true;
}

return isValid;
}

//AJAX function - will reload table if succesfull
var updateJSON = function(data, tableObj, act){
  
  var dt = tableObj.s.dt;

  var jqxhr =
  $.ajax({
    url: "php/" + dt.context[0].sTableId + ".php",
    type : "POST",
    cache: false,
    data: {
      raw: data,
      action: act
    }
  })
  .done (function(data) { 

    //If data = false, then data is already present
    //Server doesn't allow duplicate data.
    if(data === "false"){
      $('#altEditor-modal .modal-body .alert').remove();

      var message = '<div class="alert alert-danger" role="alert">\
      <strong>Fail!</strong> Data already exists.\
      </div>';
      $('#altEditor-modal .modal-body').append(message); 
    }else{
      $('#altEditor-modal .modal-body .alert').remove();

      var message = '<div class="alert alert-success" role="alert">\
      <strong>Success!</strong>\
      </div>';
      $('#altEditor-modal .modal-body').append(message); 
      
      //Reload data from server to table
      dt.ajax.reload();

      //Disabling submit button
       $("#"+act+"Btn").prop('disabled', true);
  
    }
  })
  .fail (function(error)  { 

   $('#altEditor-modal .modal-body .alert').remove();

   var message = '<div class="alert alert-danger" role="alert">\
   <strong>Error!</strong> Reponse code: ' + error.status + '\
   </div>';

   $('#altEditor-modal .modal-body').append(message); });

}
