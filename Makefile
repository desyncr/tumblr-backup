TARGET ?= "gypsy-charlatan.tumblr.com"

dump:
	TUMBLR_URL=${TARGET} ruby ./tumblr.rb
tar:
	tar -cvf ${TARGET}.tar.gz ${TARGET}
