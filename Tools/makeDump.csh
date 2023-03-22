#!/bin/csh
cmsenv

if ("$5" == "Prod") then
     echo "connectstring = frontier://FrontierProd/CMS_CONDITIONS"
     set connectstring = frontier://FrontierProd/CMS_CONDITIONS
else if ("$5" == "Prep") then
     echo "connectstring = frontier://FrontierPrep/CMS_CONDITIONS"
     set connectstring = frontier://FrontierPrep/CMS_CONDITIONS
else
    echo "connectstring = sqlite:$5"
    set connectstring = sqlite:$5
endif

cat >! temp_dump_cfg.py <<%

import FWCore.ParameterSet.Config as cms



process = cms.Process("DUMP")
process.load("Configuration.Geometry.GeometryExtended$1_cff")
process.load("Configuration.Geometry.GeometryExtended$1Reco_cff")
process.load('Configuration.StandardSequences.Services_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(1)
)

process.source = cms.Source("EmptySource",
    numberEventsInRun = cms.untracked.uint32(1),
    firstRun = cms.untracked.uint32($4)
)

process.load("CondCore.CondDB.CondDB_cfi")
process.CondDB.connect = '$connectstring'

process.PoolDBESSource = cms.ESSource("PoolDBESSource",
                                      process.CondDB,
                                      timetype = cms.string('runnumber'),
                                      toGet = cms.VPSet(cms.PSet(record = cms.string("Hcal$2Rcd"),
                                                                 tag = cms.string("$3")
                                                                 )
                                                        )
                                      )

process.dumpcond = cms.EDAnalyzer("HcalDumpConditions",
                                  dump = cms.untracked.vstring("$2")
                                  )

process.p = cms.Path(process.dumpcond)

%
cmsRun temp_dump_cfg.py
rm temp_dump_cfg.py
%
