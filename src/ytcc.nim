from std/strformat import fmt

from pkg/ytextractor import extractVideo, extractCaptions, captionsBySeconds,
                              ExtractError, parseChapters

proc main(video: seq[string]; lang = "en"; markdown = true) =
  ## A CLI tool to get the Youtube video transcript with chapters
  if video.len != 1:
    quit "Provide ONE video"
  let
    vid = extractVideo video[0]
    videoUrl = fmt"https://youtu.be/{vid.id}?t"
  if vid.status.error != ExtractError.None:
    quit "Error: " & $vid.status.error
  var url = ""
  echo "Available captions:"
  for capt in vid.captions:
    if capt.langCode == lang:
      url = capt.url
      echo fmt"- {capt.langCode} <-"
    else:
      echo fmt"- {capt.langCode}"
  if url.len == 0:
    echo fmt"Fallback caption: {vid.captions[0].langCode}"
    url = vid.captions[0].url
  let
    cc = url.extractCaptions.texts.captionsBySeconds
    chapters = parseChapters vid.description
  if chapters.len > 0 and chapters[0].second == 0:
      if markdown:
        echo fmt"## {chapters[0].name}"
      else:
        echo chapters[0].name
  for c in cc:
    for chapter in chapters:
      if chapter.second > 0 and chapter.second == c.second:
        if markdown:
          echo fmt"## {chapter.name}"
        else:
          echo chapter.name
    if markdown:
      echo fmt"[{c.text}]({videoUrl}={c.second})"
    else:
      echo c.text

when isMainModule:
  import pkg/cligen
  dispatch main
