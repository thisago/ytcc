from std/strformat import fmt

from pkg/ytextractor import extractVideo, extractCaptions, captionsBySeconds,
                              ExtractError, parseChapters

proc main(video: seq[string]; lang = "en"; html = false) =
  ## A CLI tool to get the Youtube video transcript with chapters
  if video.len != 1:
    quit "Provide ONE video"
  let
    vid = extractVideo video[0]
    videoUrl = fmt"https://youtu.be/{vid.id}"
  if vid.status.error != ExtractError.None:
    quit "Error: " & $vid.status.error
  var url = ""
  if not html: echo "Available captions:"
  for capt in vid.captions:
    if capt.langCode == lang:
      url = capt.url
      if not html: echo fmt"- {capt.langCode} <-"
    elif not html:
      echo fmt"- {capt.langCode}"
  if url.len == 0:
    if not html: echo fmt"Fallback caption: {vid.captions[0].langCode}"
    url = vid.captions[0].url
  let
    cc = url.extractCaptions.texts.captionsBySeconds
    chapters = parseChapters vid.description
  if html:
    stdout.write fmt"""<h1><a href="{videoUrl}">{vid.title}</a></h1>"""
    stdout.write "<ul>" &
      fmt"<li>Channel: {vid.channel.name}</li>" &
      fmt"<li>Likes: {vid.likes}</li>" &
      fmt"<li>Description: {vid.description}</li>" &
    "</ul>"
  if chapters.len > 0 and chapters[0].second == 0:
      if html:
        stdout.write fmt"<h2>{chapters[0].name}</h2>"
      else:
        echo chapters[0].name
  for c in cc:
    for chapter in chapters:
      if chapter.second > 0 and chapter.second == c.second:
        if html:
          stdout.write fmt"<h2>{chapter.name}</h2>"
        else:
          echo chapter.name
    if html:
      stdout.write fmt"""<a href="{videoUrl}?t={c.second}">{c.text}</a><br>"""
    else:
      echo c.text

when isMainModule:
  import pkg/cligen
  dispatch main
