brawl.data = {}

function brawl.data.init()

	brawl.points.initData()
	brawl.points.load()

end
-- hook.Add( "DatabaseInitialized", "brawl.data", brawl.data.init )
timer.Simple( 0, brawl.data.init )
