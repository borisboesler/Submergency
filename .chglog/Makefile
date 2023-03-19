# Project:     Submergency
# File name:   .chglog/Makefile
# Purpose:     generate the CHANGELOG.tpl.md from a template
# Author:      Boris Boesler
# Modified by:
# Created:     08.06.2022
# Copyright:   (c) 2022 Boris Boesler


# tools
M4 = m4

# files
CLTemplateTemplate = CHANGELOG.tpl.m4
CLTemplate = CHANGELOG.tpl.md

all:	$(CLTemplate)

%.md:	%.m4
	$(M4) $^ > $@
