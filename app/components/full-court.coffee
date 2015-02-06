`import Ember from 'ember'`

FullCourtComponent = Ember.Component.extend
  classNames: ["full-court"]
  click: (event) ->
    unless @get('selectedPlayer')
      return

    courtWidth = parseInt(@.$().width())
    courtHeight = parseInt(courtWidth / 1.766)
    offset = @.$().offset()
    top = offset.top - $(window).scrollTop()
    left = offset.left

    mx = event.clientX
    my = event.clientY

    y = ((my - top) / courtHeight) - .02
    x = (mx - left) / courtWidth

    if @get('selectedPlayer.team.id') is @get('model.right.id')
      x = (.99-x)
      y = (.96-y)

    # console.log "y: ", y
    # console.log "x: ", x

    if x <= 0.09592512771392082
      if y < 0.1 or y > 0.9
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.014188218390804598
      if y < 0.09932279909706546 or y > (1-0.09932279909706546)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.09337084929757343
      if y < 0.09932279909706546 or y > (1-0.09932279909706546)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.09592512771392082
      if y < 0.09932279909706546 or y > (1-0.09932279909706546)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.09975654533844189
      if y < 0.1038374717832957 or y > (1-0.1038374717832957)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.10486510217113665
      if y < 0.1038374717832957 or y > (1-0.1038374717832957)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.10997365900383142
      if y < 0.1038374717832957 or y > (1-0.1038374717832957)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.11380507662835249
      if y < 0.10609480812641084 or y > (1-0.10609480812641084)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.11763649425287356
      if y < 0.10835214446952596 or y > (1-0.10835214446952596)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.12146791187739464
      if y < 0.10835214446952596 or y > (1-0.10835214446952596)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.12529932950191572
      if y < 0.11060948081264109 or y > (1-0.11060948081264109)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.12913074712643677
      if y < 0.11286681715575621 or y > (1-0.11286681715575621)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.13423930395913156
      if y < 0.11512415349887133 or y > (1-0.11512415349887133)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.14190213920817368
      if y < 0.11963882618510158 or y > (1-0.11963882618510158)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.14828783524904215
      if y < 0.12415349887133183 or y > (1-0.12415349887133183)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.15339639208173692
      if y < 0.12641083521444696 or y > (1-0.12641083521444696)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.15978208812260536
      if y < 0.12866817155756208 or y > (1-0.12866817155756208)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.16616778416347383
      if y < 0.13544018058690746 or y > (1-0.13544018058690746)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.16999920178799488
      if y < 0.13769751693002258 or y > (1-0.13769751693002258)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.16999920178799488
      if y < 0.13769751693002258 or y > (1-0.13769751693002258)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.17255348020434227
      if y < 0.1399548532731377 or y > (1-0.1399548532731377)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.17893917624521072
      if y < 0.14221218961625282 or y > (1-0.14221218961625282)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.18404773307790548
      if y < 0.1489841986455982 or y > (1-0.1489841986455982)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.18787915070242656
      if y < 0.15124153498871332 or y > (1-0.15124153498871332)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.19043342911877395
      if y < 0.15349887133182843 or y > (1-0.15349887133182843)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.1980962643678161
      if y < 0.16027088036117382 or y > (1-0.16027088036117382)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.20320482120051087
      if y < 0.16930022573363432 or y > (1-0.16930022573363432)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.20703623882503192
      if y < 0.16930022573363432 or y > (1-0.16930022573363432)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.210867656449553
      if y < 0.17381489841986456 or y > (1-0.17381489841986456)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.21469907407407407
      if y < 0.18058690744920994 or y > (1-0.18058690744920994)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.21980763090676883
      if y < 0.18510158013544017 or y > (1-0.18510158013544017)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2236390485312899
      if y < 0.18961625282167044 or y > (1-0.18961625282167044)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.22747046615581099
      if y < 0.19413092550790068 or y > (1-0.19413092550790068)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.23130188378033206
      if y < 0.20090293453724606 or y > (1-0.20090293453724606)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.23385616219667943
      if y < 0.20316027088036118 or y > (1-0.20316027088036118)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2389647190293742
      if y < 0.20993227990970656 or y > (1-0.20993227990970656)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.24151899744572158
      if y < 0.2144469525959368 or y > (1-0.2144469525959368)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.24279613665389527
      if y < 0.21896162528216703 or y > (1-0.21896162528216703)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.24662755427841634
      if y < 0.2234762979683973 or y > (1-0.2234762979683973)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2517361111111111
      if y < 0.2325056433408578 or y > (1-0.2325056433408578)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2568446679438059
      if y < 0.23927765237020315 or y > (1-0.23927765237020315)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2619532247765006
      if y < 0.2505643340857788 or y > (1-0.2505643340857788)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2670617816091954
      if y < 0.2595936794582393 or y > (1-0.2595936794582393)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.27217033844189015
      if y < 0.2708803611738149 or y > (1-0.2708803611738149)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.27472461685823757
      if y < 0.27539503386004516 or y > (1-0.27539503386004516)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.27727889527458494
      if y < 0.28216704288939054 or y > (1-0.28216704288939054)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.281110312899106
      if y < 0.29345372460496616 or y > (1-0.29345372460496616)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2849417305236271
      if y < 0.30248306997742663 or y > (1-0.30248306997742663)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.28749600893997446
      if y < 0.3115124153498871 or y > (1-0.3115124153498871)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2900502873563218
      if y < 0.3182844243792325 or y > (1-0.3182844243792325)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.29260456577266925
      if y < 0.327313769751693 or y > (1-0.327313769751693)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.2951588441890166
      if y < 0.34085778781038373 or y > (1-0.34085778781038373)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.29899026181353766
      if y < 0.35214446952595935 or y > (1-0.35214446952595935)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.30026740102171134
      if y < 0.3611738148984199 or y > (1-0.3611738148984199)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3015445402298851
      if y < 0.37020316027088035 or y > (1-0.37020316027088035)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.30282167943805877
      if y < 0.37697516930022573 or y > (1-0.37697516930022573)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.30537595785440613
      if y < 0.3860045146726862 or y > (1-0.3860045146726862)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.30537595785440613
      if y < 0.39503386004514673 or y > (1-0.39503386004514673)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3079302362707535
      if y < 0.40632054176072235 or y > (1-0.40632054176072235)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3104845146871009
      if y < 0.417607223476298 or y > (1-0.417607223476298)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3117616538952746
      if y < 0.42663656884875845 or y > (1-0.42663656884875845)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3130387931034483
      if y < 0.435665914221219 or y > (1-0.435665914221219)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.3130387931034483
      if y < 0.4492099322799097 or y > (1-0.4492099322799097)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.31431593231162197
      if y < 0.4604966139954853 or y > (1-0.4604966139954853)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.31431593231162197
      if y < 0.4717832957110609 or y > (1-0.4717832957110609)
        shotType = "3"
      else
        shotType = "2"
    else if x <= 0.31559307151979565
      if y < 0.48306997742663654 or y > (1-0.48306997742663654)
        shotType = "3"
      else
        shotType = "2"
    else
      shotType = "3"

    if shotType is "2" and x < .1445 and y > .37 and y < .63
      shotType = "close2"

    value = 2
    message = "2pt Shot"
    closeShot = false
    if shotType is "3"
      message = "3pt Shot"
      value = 3
    if shotType is "close2"
      closeShot = true

    @sendAction('action', {type: shotType, subType: "jumper", x: x, y: y, message: message, closeShot: closeShot, value: value})
`export default FullCourtComponent`
