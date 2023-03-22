#!/bin/csh
cmsenv

if ("$6" == "db") then
    echo "Loading to ORCON!"
    echo "connectstring = frontier://cms_orcon_prod/CMS_COND_31X_HCAL"
    set connectstring = frontier://cms_orcon_prod/CMS_COND_31X_HCAL
    set authPath = /nfshome0/popcondev/conddb
    set logstring = frontier ://cms_orcon_prod/CMS_COND_31X_POPCONLOG
else if ( $#argv == 5 ) then
     echo "Insert DB file"
else 
    echo "Loading to sqlite_file: $6"
    set connectstring = sqlite_file:$6
    set logstring = sqlite_file:log_$6
    set authPath =
endif


cat >! temp_write_cfg.py <<%

import FWCore.ParameterSet.Config as cms

process = cms.Process("ProcessOne")

process.load("Configuration.StandardSequences.GeometryDB_cff")
process.load("Configuration.StandardSequences.FrontierConditions_GlobalTag_cff")
from Configuration.AlCa.autoCond import autoCond
process.GlobalTag.globaltag = autoCond["phase1_$1_realistic"]

process.load("CondCore.CondDB.CondDB_cfi")

process.CondDB.DBParameters.authenticationPath = cms.untracked.string('$authPath' )
process.CondDB.connect = cms.string('$connectstring')


process.MessageLogger = cms.Service("MessageLogger",
    cout = cms.untracked.PSet(
        default = cms.untracked.PSet(
            limit = cms.untracked.int32(0)
        )
    ),
    destinations = cms.untracked.vstring('cout')
)

process.source = cms.Source("EmptyIOVSource",
    timetype = cms.string('runnumber'),
    firstValue = cms.uint64(1),
    lastValue = cms.uint64(1),
    interval = cms.uint64(1)
)

process.es_ascii = cms.ESSource("HcalTextCalibrations",
    input = cms.VPSet(cms.PSet(
        object = cms.string('$2'),
        file = cms.FileInPath('$3')
    ))
)

process.prefer("es_ascii")

process.PoolDBOutputService = cms.Service("PoolDBOutputService",
    process.CondDB,
    logconnect = cms.untracked.string('$logstring'),
    timetype = cms.untracked.string('runnumber'),
#     timetype = cms.untracked.string('lumiid'),
    toPut = cms.VPSet(cms.PSet(
        record = cms.string('Hcal$2Rcd'),
        tag = cms.string("$4")
    ))
)
process.WriteInDB = cms.EDAnalyzer("Hcal$2PopConAnalyzer",
    SinceAppendMode = cms.bool(True),
    record = cms.string('Hcal$2Rcd'),
    loggingOn = cms.untracked.bool(True),
   Source = cms.PSet(
        IOVRun = cms.untracked.uint32($5)
    )
)

process.p = cms.Path(process.WriteInDB)
%
cmsRun temp_write_cfg.py
rm temp_write_cfg.py

