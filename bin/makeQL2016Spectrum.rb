#!/usr/local/bin/ruby

require "RubyFits"
require "RubyROOT"
include Math
include Root
include RootApp

if (ARGV[2]==nil) then
  puts "Usage: ruby makeSpectrum.rb <input file> <channel> <rebin>"
  exit 1
end
  
fitsFile=ARGV[0]
adcChannel=ARGV[1].to_i
rebin=ARGV[2].to_i
fits=Fits::FitsFile.new(fitsFile)
eventHDU=fits["EVENTS"]
adcIndex=eventHDU["boardIndexAndChannel"]
eventNum=eventHDU.getNRows()-1

startTimeTag=eventHDU["timeTag"][0].to_i
stopTimeTag=eventHDU["timeTag"][eventNum].to_i

if stopTimeTag<startTimeTag then
  observationTime=(stopTimeTag-startTimeTag+2**40).to_f/1.0e8
else
  observationTime=(stopTimeTag-startTimeTag).to_f/1.0e8
end

binNum=4096/rebin

hist=Root::TH1F.create("hist", "hist", binNum, -0.5, 4095.5)

for i in 0..eventNum
  if adcIndex[i].to_i==adcChannel then
      hist.Fill(eventHDU["phaMax"][i].to_i)
  end
end

scaleFactor=1.0/(observationTime*rebin.to_f)
c0=Root::TCanvas.create("c0", "canvas0", 640, 480)
hist.SetTitle("")
hist.GetXaxis.SetTitle("Channel")
hist.GetXaxis.SetTitleOffset(1.2)
hist.GetXaxis.CenterTitle
hist.GetYaxis.SetTitle("Count/s/ch")
hist.GetYaxis.CenterTitle
hist.GetYaxis.SetTitleOffset(1.35)
#hist.GetYaxis.SetRangeUser(0.5, 100000)
hist.GetXaxis.SetRangeUser(2048, 4096)
hist.SetStats(0)
hist.Sumw2()
hist.Scale(scaleFactor)
hist.Draw("e1")
c0.SetLogy()
c0.Update
run_app()
