describe 'FlatToppedMap', ->
  Subject = Hexagonal.FlatToppedMap

  # SHARED
  it 'is defined in the Hexagonal namespace', ->
    expect(Subject).not.toBeUndefined()

  describe 'constructor', ->
    describe 'when cols and rows are provided', ->
      subject = null
      beforeEach -> subject = new Subject hexagon: { height: 10 }, cols: 5, rows: 6

      # SHARED
      it 'creates cols*rows hexagons', ->
        expect(subject.hexagons().length).toEqual 30

      # SHARED
      it 'each item in the hexagons collection is filled with an hexagon', ->
        for hexagon in subject.hexagons()
          throw new Error index unless hexagon?
          expect(hexagon.constructor.name).toEqual 'Hexagon'

      # SHARED
      it 'each hexagon has the same size', ->
        firstHexagon = subject.hexagons()[0]
        for hexagon, index in subject.hexagons() when index > 0
          expect(hexagon.size()).toEqual firstHexagon.size()

      it 'each hexagon in an even column has the expected position', ->
        for hexagon, index in subject.hexagons()
          [row, col] = [Math.floor(index / 5), index % 5]
          continue if col % 2 isnt 0
          expectedPosition = new Hexagonal.Point
            x: subject._round(col * subject._round(0.75 * hexagon.size().width)),
            y: subject._round(row * hexagon.size().height)
          expect(hexagon.position()).toEqual expectedPosition

      it 'each hexagon in an odd column has the expected position', ->
        for hexagon, index in subject.hexagons()
          [row, col] = [Math.floor(index / 5), index % 5]
          continue if col % 2 is 0
          expectedPosition = new Hexagonal.Point
            x: subject._round(col * subject._round(0.75 * hexagon.size().width)),
            y: subject._round(hexagon.size().height / 2 + subject._round(row * hexagon.size().height))
          expect(hexagon.position()).toEqual expectedPosition

      it 'each hexagon on the same column shares two vertices with the previous one', ->
        for hexagon, index in subject.hexagons()
          [row, col] = [Math.floor(index / 5), index % 5]
          continue if row is 0
          previousOne = subject.at row - 1, col
          expect(hexagon.vertices()[4]).toBe previousOne.vertices()[2]
          expect(hexagon.vertices()[5]).toBe previousOne.vertices()[1]

      it 'each hexagon on the same column shares one edge with the previous one', ->
        for hexagon, index in subject.hexagons()
          [row, col] = [Math.floor(index / 5), index % 5]
          continue if row is 0
          previousOne = subject.at row - 1, col
          expect(hexagon.halfEdges[4].edge).toBe previousOne.halfEdges[1].edge

      describe 'each hexagon in an odd column', ->
        it 'shares two vertices with its neighbor in 0/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip even cols and first row
            continue if col % 2 is 0 or row is 0
            neighbor = subject.at row, col - 1
            unless hexagon.vertices()[4] is neighbor.vertices()[0]
              throw new Error 'asd'
            expect(hexagon.vertices()[3]).toBe neighbor.vertices()[1]
            expect(hexagon.vertices()[4]).toBe neighbor.vertices()[0]

        it 'shares one edge with its neighbor in 0/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip even cols and first row
            continue if col % 2 is 0 or row is 0
            neighbor = subject.at row, col - 1
            expect(hexagon.halfEdges[3].edge).toBe neighbor.halfEdges[0].edge

      describe 'each hexagon in an even col', ->
        it 'shares two vertices with its neighbor in -1/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the first column and odd cols
            continue if row is 0 or col is 0 or col % 2 isnt 0
            neighbor = subject.at row - 1, col - 1
            expect(hexagon.vertices()[3]).toBe neighbor.vertices()[1]
            expect(hexagon.vertices()[4]).toBe neighbor.vertices()[0]

        it 'shares two vertices with its neighbor in 0/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the first col and odd cols
            continue if row is 0 or col is 0 or col % 2 isnt 0
            neighbor = subject.at row, col - 1
            expect(hexagon.vertices()[2]).toBe neighbor.vertices()[0]
            expect(hexagon.vertices()[3]).toBe neighbor.vertices()[5]

        it 'shares two vertices with its neighbor in -1/+1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the last col and odd cols
            continue if row is 0 or col is 4 or col % 2 isnt 0
            neighbor = subject.at row - 1, col + 1
            expect(hexagon.vertices()[0]).toBe neighbor.vertices()[2]
            expect(hexagon.vertices()[5]).toBe neighbor.vertices()[3]

        it 'shares one edge with its neighbor in -1/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the first col and odd cols
            continue if row is 0 or col is 0 or col % 2 isnt 0
            neighbor = subject.at row - 1, col - 1
            expect(hexagon.halfEdges[3].edge).toBe neighbor.halfEdges[0].edge

        it 'shares one edge with its neighbor in 0/-1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the first col and odd cols
            continue if row is 0 or col is 0 or col % 2 isnt 0
            neighbor = subject.at row, col - 1
            expect(hexagon.halfEdges[2].edge).toBe neighbor.halfEdges[5].edge

        it 'shares one edge with its neighbor -1/+1', ->
          for hexagon, index in subject.hexagons()
            [row, col] = [Math.floor(index / 5), index % 5]
            # skip the first row, the last col and odd cols
            continue if row is 0 or col is 4 or col % 2 isnt 0
            neighbor = subject.at row - 1, col + 1
            expect(hexagon.halfEdges[5].edge).toBe neighbor.halfEdges[2].edge