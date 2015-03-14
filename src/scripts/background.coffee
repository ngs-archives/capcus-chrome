'use strict'

# CAPCUS_URL = 'http://127.0.0.1:3000/capcus'
CAPCUS_URL = 'https://capcus.herokuapp.com/capcus'

userId = null

guid = ->
  s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}"

chrome.storage.sync.get ['userId'], (items) ->
  unless userId = items.userId
    userId = guid()
    chrome.storage.sync.set { userId }

## https://gist.github.com/erkie/2730276

cropData = (str, params, coords, callback) ->
  img = new Image()
  img.onload = ->
    {x, y, w, h} = coords
    canvas = document.createElement 'canvas'
    canvas.width = w
    canvas.height = h
    ctx = canvas.getContext '2d'
    ctx.drawImage img, x, y, w, h, 0, 0, w, h
    fd = new FormData()
    fd.append 'image', dataURItoBlob canvas.toDataURL()
    for k, v of params
      fd.append k, v
    xhr = new XMLHttpRequest()
    xhr.responseType = 'json'
    xhr.onreadystatechange = ->
      if xhr.readyState == 4
        callback xhr.response
      return
    xhr.open 'POST', CAPCUS_URL
    xhr.send fd
  img.src = str
  return

capture = (params, coords) ->
  chrome.tabs.captureVisibleTab null, { format: 'png' }, (data) ->
    cropData data, params, coords, (res) ->
      chrome.tabs.create url: res.url, active: yes

gotMessage = (request, sender, sendResponse) ->
  if request.type == 'coords'
    {pageUrl, coords} = request
    capture {pageUrl, userId}, coords
  sendResponse {}
  # snub them.
  return

sendMessage = (msg) ->
  chrome.tabs.getSelected null, (tab) ->
    chrome.tabs.sendRequest tab.id, msg, (response) ->
    return
  return

dataURItoBlob = (dataURI) ->
  # convert base64 to raw binary data held in a string
  # doesn't handle URLEncoded DataURIs
  byteString = atob(dataURI.split(',')[1])
  # separate out the mime component
  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
  # write the bytes of the string to an ArrayBuffer
  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  # write the ArrayBuffer to a blob, and you're done
  b = new Blob [ab]
  b.type = mimeString
  b

chrome.extension.onRequest.addListener gotMessage

chrome.contextMenus.create title: 'Capcus', onclick: ->
  sendMessage type: 'start-screenshots'

