module Main where
import Data.Maybe
import Data.List.Split
import qualified Data.Map as Map

data Gate = Gate { in1 :: String, in2 :: String, op :: String, out :: String } deriving Show

isOutZGate :: Gate -> Bool
isOutZGate = isZWire . out
isZWire :: String -> Bool
isZWire wire = wire !! 0 == 'z'

processGates :: Map.Map String Bool -> [Gate] -> [Gate] -> Int -> Int -> Map.Map String Bool
processGates wires [] newGates zCount zCurrent | zCurrent >= zCount = wires
                                               | length newGates == 0 = error "Could not calculate result for all z wires."
                                               | otherwise = processGates wires (reverse newGates) [] zCount zCurrent
processGates wires (g:gs) newGates zCount zCurrent | zCurrent >= zCount = wires
                                                   | v1 /= Nothing && v2 /= Nothing =
                                                       let result = case op g of
                                                            "AND" -> fromJust v1 && fromJust v2
                                                            "OR" -> fromJust v1 || fromJust v2
                                                            "XOR" -> v1 /= v2
                                                       in processGates (Map.insert (out g) result wires) gs newGates zCount $ zCurrent + fromEnum (isOutZGate g)
                                                   | otherwise = processGates wires gs (g : newGates) zCount zCurrent
    where v1 = Map.lookup (in1 g) wires
          v2 = Map.lookup (in2 g) wires

main :: IO ()
main = do
    initContent <- readFile "input-init.txt"
    gatesContent <- readFile "input-gates.txt"
    let wires = Map.fromList $ map ((\[k, v] -> (k, v == "1")) . splitOn ": ") $ lines initContent
        gates = map ((\[in1, op, in2, _, out] -> Gate { in1 = in1, in2 = in2, op = op, out = out }) . words) $ lines gatesContent
        zGateCount = length $ filter isOutZGate gates
        newWires = processGates wires gates [] zGateCount 0
        zValues = Map.elems $ Map.filterWithKey (const . isZWire) newWires
    print $ foldr (\(_, n) b -> 2^n + b) 0 $ filter fst $ zip zValues [0..]
