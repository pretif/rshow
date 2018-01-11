# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


#= require jquery.xdan.datetimepicker.full

@setupDateTimePicker = (container) ->
  defaults = {
    formatDate: 'y-m-d',
    format: 'Y-m-d H:i',
    allowBlank: true,
    defaultSelect: false,
    validateOnBlur: false
  }

  entries = $(container).find('input.datetimepicker')
  entries.each (index, entry) ->
    options = $(entry).data 'datepicker-options'
    $(entry).datetimepicker $.extend(defaults, options)

$ ->
  setupDateTimePicker $('body')