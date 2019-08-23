let loose = false, win = false, inGame = false, iterator, position, resmessage = '', start_difficulty="Junior", end_difficulty="", buttons_menu = false, too_many_mines = false

const RIGHT_CLICK = 2


tag Tile < button
  # called when a touch starts
  def ontouchstart touch
    if touch.button == RIGHT_CLICK
      trigger('set_flag', data)
    <self :tab.prevent.ontouchstart>


tag App
  prop fieldWidth
  prop fieldHeight
  prop newfieldWidth
  prop newfieldHeight
  prop fieldRect
  prop poops
  prop newpoops
  prop field
  prop wasThere
  prop flags

  def build
    @fieldWidth = 9
    @fieldHeight = 9
    @newfieldWidth = 9
    @newfieldHeight = 9
    @fieldRect = fieldWidth * fieldHeight
    @poops = 10
    @newpoops = 10
    @field = []
    @wasThere = []
    @flags = 0

  def getRandomInt max
    return Math.floor(Math.random() * Math.floor(max))

  def buildNewField
    # Fill array with poops
    iterator = 0
    while iterator < fieldRect
      field.push({
              has_poops: 0,
              near: 0,
              taped: false,
              flag: false,
            })
      iterator++

    # Set poops rundomly on the field
    iterator = 0
    while iterator < poops
      position = getRandomInt(fieldRect)
      if !field[position]:has_poops
        field[position]:has_poops = 1
      else iterator--
      iterator++

    fieldWidth = parseInt(fieldWidth)

    # Near counter
    iterator = 0
    while iterator < fieldRect
      if (iterator - 1 >= 0) && (iterator % fieldWidth != 0)
        field[iterator]:near += field[iterator - 1]:has_poops
      if (iterator + 1 < fieldRect) && (((iterator + 1) % fieldWidth) != 0)
        field[iterator]:near += field[iterator + 1]:has_poops
      if ((iterator - fieldWidth + 1) >= 0) && (((iterator - fieldWidth + 1) % fieldWidth) != 0)
        field[iterator]:near += field[iterator - fieldWidth + 1]:has_poops
      if (iterator - fieldWidth >= 0)
        field[iterator]:near += field[iterator - fieldWidth]:has_poops
      if ((iterator - fieldWidth - 1) >= 0) && ((iterator - fieldWidth) % fieldWidth != 0)
        field[iterator]:near += field[iterator - fieldWidth - 1]:has_poops
      if (iterator + fieldWidth - 1 < fieldRect) && (iterator % fieldWidth != 0)
        field[iterator]:near += field[iterator + fieldWidth - 1]:has_poops
      if (iterator + fieldWidth < fieldRect)
        field[iterator]:near += field[iterator + parseInt(fieldWidth)]:has_poops
      if ((iterator + fieldWidth + 1) < fieldRect) && ((iterator + fieldWidth + 1) % fieldWidth != 0)
        field[iterator]:near += field[iterator + fieldWidth + 1]:has_poops
      iterator++

  def setup
    buildNewField()

  def newField
    # Verify new dimentions
    if newpoops >= newfieldWidth * newfieldHeight || newpoops < 5 || newfieldWidth > 40 || newfieldHeight > 40
      too_many_mines = true
      return

    # Clear variables
    buttons_menu = false
    inGame = true
    loose = false
    win = false
    flags = 0
    wasThere = []
    field = []
    poops = newpoops
    fieldWidth = newfieldWidth
    fieldHeight = newfieldHeight
    fieldRect = fieldWidth * fieldHeight
    if newpoops == 10 && newfieldWidth == newfieldHeight == 9
      start_difficulty ="Junior"
    elif newpoops == 40 && newfieldWidth == newfieldHeight == 16
      start_difficulty = "Middle"
    elif newpoops == 99 && newfieldWidth == newfieldHeight == 24
      start_difficulty = "Senior"
    else
      start_difficulty = "Custom"
    end_difficulty = start_difficulty
    buildNewField()
    Imba.commit

  def openEmptyTiles emptyTileIndex
    if field[emptyTileIndex]:flag
      field[emptyTileIndex]:flag = false
    flags++
    wasThere.push(emptyTileIndex)
    parseInt(field[emptyTileIndex]:near)
    field[emptyTileIndex]:taped = true
    if field[emptyTileIndex]:near > 0
      return

    if (emptyTileIndex + 1 < fieldRect) && (((emptyTileIndex + 1) % fieldWidth) != 0) && !wasThere.includes(emptyTileIndex + 1)
      openEmptyTiles(emptyTileIndex + 1)
    if ((emptyTileIndex + fieldWidth + 1) < fieldRect) && ((emptyTileIndex + fieldWidth + 1) % fieldWidth != 0) && !wasThere.includes(emptyTileIndex + fieldWidth + 1)
      openEmptyTiles(emptyTileIndex + fieldWidth + 1)
    if (emptyTileIndex + fieldWidth < fieldRect) && !wasThere.includes(emptyTileIndex + fieldWidth)
      openEmptyTiles(emptyTileIndex + fieldWidth)
    if (emptyTileIndex + fieldWidth - 1 < fieldRect) && (emptyTileIndex % fieldWidth != 0) && !wasThere.includes(emptyTileIndex + fieldWidth - 1)
      openEmptyTiles(emptyTileIndex + fieldWidth - 1)
    if (emptyTileIndex - 1 >= 0) && (emptyTileIndex % fieldWidth != 0) && !wasThere.includes(emptyTileIndex - 1)
      openEmptyTiles(emptyTileIndex - 1)
    if ((emptyTileIndex - fieldWidth - 1) >= 0) && ((emptyTileIndex - fieldWidth) % fieldWidth != 0) && !wasThere.includes(emptyTileIndex - fieldWidth - 1)
      openEmptyTiles(emptyTileIndex - fieldWidth - 1)
    if (emptyTileIndex - fieldWidth >= 0) && !wasThere.includes(emptyTileIndex - fieldWidth)
      openEmptyTiles(emptyTileIndex - fieldWidth)
    if ((emptyTileIndex - fieldWidth + 1) >= 0) && (((emptyTileIndex - fieldWidth + 1) % fieldWidth) != 0) && !wasThere.includes(emptyTileIndex - fieldWidth + 1)
      openEmptyTiles(emptyTileIndex - fieldWidth + 1)

  def verify choosen
    if !loose && !win && !field[choosen]:flag && !field[choosen]:taped
      if field[choosen]:has_poops
        iterator = 0
        while iterator < fieldRect
          if field[iterator]:has_poops
            field[iterator]:taped = true
          iterator++
        loose = true
        inGame = false
        resmessage = "Lost"
      elif field[choosen]:near > 0
        flags++
        field[choosen]:taped = true
        wasThere.push(choosen)
      else
        openEmptyTiles(choosen)
      if flags >= fieldRect - poops
        win = true
        inGame = false
        resmessage = "Win"
      console.log flags, fieldRect - poops
      Imba.commit

  def choose_difficulty option
    if option == "Junior"
      start_difficulty = "Junior"
      newfieldWidth = 9
      newfieldHeight = 9
      newpoops = 10
    elif option == "Middle"
      start_difficulty = "Middle"
      newfieldWidth = 16
      newfieldHeight = 16
      newpoops = 40
    elif option == "Senior"
      start_difficulty = "Senior"
      newfieldWidth = 24
      newfieldHeight = 24
      newpoops = 99
    else
      start_difficulty = "Custom"
    show_options


  def show_options
    buttons_menu = !buttons_menu

  def onset_flag e
    if e.data == undefined
      e.data = 0
    if !field[e.data]:taped && !win && !loose
      field[e.data]:flag = !field[e.data]:flag
    return

  def grid_columns
    return "repeat({fieldWidth}, 1fr)"

  def hide_error_blok
    too_many_mines = false


  def render
    <self>
      <ul.menu .hide_menu=inGame>
        <li>
          <div.status>
            <label> "Your status"
            if resmessage
              if resmessage=="Lost"
                <div.winloose.poopswin>
              else
                <div.winloose.{end_difficulty}>
          <button.select :tap.show_options>
            if start_difficulty == "Junior"  && newpoops == 10 && newfieldWidth == newfieldHeight == 9
              <img.img src="images/boy.png">
              start_difficulty
            elif start_difficulty == "Middle"  && newpoops == 40 && newfieldWidth == newfieldHeight == 16
              <img.img src="images/bearded_person.png">
              start_difficulty
            elif start_difficulty == "Senior"  && newpoops == 99 && newfieldWidth == newfieldHeight == 24
              <img.img src="images/wizard.png">
              start_difficulty
            else
              <img.img src="images/alien.png">
              "Custom"
          <div.buttons .show=buttons_menu>
            <button.junior .btn=buttons_menu :tap.choose_difficulty("Junior")>
              <img.img src="images/boy.png">
              "Junior"
            <button.middle .btn=buttons_menu :tap.choose_difficulty("Middle")>
              <img.img src="images/bearded_person.png">
              "Middle"
            <button.senior .btn=buttons_menu :tap.choose_difficulty("Senior")>
              <img.img src="images/wizard.png">
              "Senior"
            <button.custom .btn=buttons_menu :tap.choose_difficulty("Custom")>
              <img.img src="images/alien.png">
              "Custom"
        <li.flex-row>
          <div.width>
            <label> "Width"
            <input[newfieldWidth] type="number" min="5" max="40" step="1" :keydown.enter.newField>
          <div.height>
            <label> "Height"
            <input[newfieldHeight] type="number" min="5" max="40" step="1" :keydown.enter.newField>
        <li>
          <label> "Poops"
          <input[newpoops] type="number" min="5" max="400" step="1" :keydown.enter.newField>
        <li>
          <button.sweep_the_poops type="submit" :tap.newField> "Sweep the poops!"

      <div.error_block .show=too_many_mines>
        <p> "Sorry. Number of poops can be from 5 to 200, and field size from 5x5 to 40x40!"
        <button.btn :tap.hide_error_blok> "Understand"

      <div.field css:grid-template-columns=grid_columns> for tile, i in field
          <Tile[i].tile
            .poop=(tile:taped && tile:has_poops)
            .empty=(tile:taped && tile:near <= 0 && tile:has_poops == 0)
            .choosen=(tile:taped && tile:near > 0 && !tile:has_poops)
            .flaged=tile:flag
            :tap.prevent.verify(i)
            >  if !tile:taped
              " "
            elif tile:has_poops
              " "
            elif tile:near
              tile:near

Imba.mount <App>
