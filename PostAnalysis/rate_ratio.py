import ROOT
import sys
import argparse
from pathlib import Path




def averageOverRange(hist, start, end):
    low = hist.FindBin(start)
    high= hist.FindBin(end)
    if high == low:
        raise Exception("Give Larger Window")
    real_start = hist.GetBinLowEdge(low)
    real_end = hist.GetBinLowEdge(high+1)
    val = hist.Integral(low, high)/(real_end-real_start)
    print(hist.Integral(low, high))
    return val


def getRatio(num,den,histo,start,end):
    num_file = ROOT.TFile.Open(str(num.resolve()), "READ")
    den_file = ROOT.TFile.Open(str(den.resolve()), "READ")

    num_hist = num_file.Get(histo)
    den_hist = den_file.Get(histo)

    num_val = averageOverRange(num_hist, start,end)
    den_val = averageOverRange(den_hist, start,end)
    return num_val/den_val



def main():
    parser = argparse.ArgumentParser(
        prog="RateRatioMaker",
        description="Take two files and one histogram name, along with a user range, and output the ratio of the average value of the histogram in the two files",
    )
    parser.add_argument("-n", "--numerator", required=True)
    parser.add_argument("-d", "--denominator", required=True)
    parser.add_argument("-g", "--histogram", required=True)
    parser.add_argument("-v", "--value", type=float, required=True)
    parser.add_argument("-w", "--window", type=float, required=True)

    args = parser.parse_args()

    num = Path(args.numerator)
    den = Path(args.denominator)
    histo = args.histogram
    start  = args.value - args.window/2
    end  = args.value + args.window/2


    val = getRatio(num,den,histo,start,end)
    sys.stdout.write("{:.3}".format(val))


if __name__ == "__main__":
    main()

    


