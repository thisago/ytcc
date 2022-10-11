from std/strformat import fmt
from std/strutils import replace

from pkg/ytextractor import extractVideo, extractCaptions, captionsBySeconds,
                              ExtractError, parseChapters, YoutubeVideo
from pkg/util/forStr import secToTimestamp

type
  ExtractedCc* = tuple
    err, html, text: string
    vid: YoutubeVideo
    availableLangs: seq[string]

proc extractCc*(video: string; lang = "en"): ExtractedCc =
  ## Get the Youtube video transcript with chapters
  let
    vid = extractVideo video
    videoUrl = fmt"https://youtu.be/{vid.id}"
  if vid.status.error != ExtractError.None:
    result.err = "Error: " & $vid.status.error
    return
  result.vid = vid
  var url = ""
  for capt in vid.captions:
    if capt.langCode == lang:
      url = capt.url
    result.availableLangs.add capt.langCode
  if url.len == 0:
    result.text.add fmt"Fallback caption: {vid.captions[0].langCode}" & "\l"
    url = vid.captions[0].url
  let
    cc = url.extractCaptions.texts.captionsBySeconds
    chapters = parseChapters vid.description

  result.html.add fmt"""<h1><a href="{videoUrl}">{vid.title}</a></h1>"""
  result.html.add fmt"""<img src="{vid.thumbnails[^1].url}">"""
  let desc = vid.description.replace("\n", "<br>")
  result.html.add "<ul>" &
    fmt"<li>Channel: {vid.channel.name}</li>" &
    fmt"<li>Views: {vid.views}</li>" &
    fmt"<li>Likes: {vid.likes}</li>" &
    fmt"<li>Published at: {$vid.publishDate}</li>" &
    fmt"<li>Transcript language: {lang}</li>" &
    fmt"<li>Description: {desc}</li>" &
  "</ul>"
  result.html.add "<hr>"
  if chapters.len > 0 and chapters[0].second == 0:
    result.html.add fmt"<h2>{chapters[0].name}</h2>"
    result.text.add chapters[0].name & "\l"
  for c in cc:
    for chapter in chapters:
      if chapter.second > 0 and chapter.second == c.second:
        result.html.add fmt"<h2>{chapter.name}</h2>"
        result.text.add chapter.name & "\l"
    result.html.add fmt"""<a href="{videoUrl}?t={c.second}">{c.text}</a><br>"""
    result.text.add secToTimestamp(c.second) & ": " & c.text & "\l"

proc main(video: seq[string]; lang = "en"; html = false; showLangs = true) =
  ## A CLI tool to get the Youtube video transcript with chapters
  if video.len != 1:
    quit "Provide ONE video"
  let res = video[0].extractCc lang
  if showLangs:
    for l in res.availableLangs:
      let selected = if lang == l: " <-" else: ""
      echo fmt"- {l}{selected}"
  if html: echo res.html
  else: echo res.text

when isMainModule:
  import pkg/cligen
  dispatch main
