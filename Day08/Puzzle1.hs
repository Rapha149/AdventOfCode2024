module Main where
import qualified Data.Map as Map
import qualified Data.Set as Set

parseLine :: String -> Int -> Int -> Map.Map Char [(Int, Int)] -> Map.Map Char [(Int, Int)]
parseLine [] _ _ m = m
parseLine (c:cs) x y m | c == '.' = parseLine cs (x + 1) y m
                       | otherwise = parseLine cs (x + 1) y $ Map.insertWith (++) c [(x, y)] m

parseLines :: [String] -> Int -> Map.Map Char [(Int, Int)] -> Map.Map Char [(Int, Int)]
parseLines [] _ m = m
parseLines (r:rs) y m = parseLines rs (y + 1) $ parseLine r 0 y m

getAntinodesForAntenna :: Int -> Int -> [(Int, Int)] -> Int -> Int -> Set.Set (Int, Int) -> Set.Set (Int, Int)
getAntinodesForAntenna _ _ [] _ _ nodes = nodes
getAntinodesForAntenna x y (a:as) maxX maxY nodes | (x == aX && y == aY) || nX < 0 || nX > maxX || nY < 0 || nY > maxY = getAntinodesForAntenna x y as maxX maxY nodes
                                                  | otherwise = getAntinodesForAntenna x y as maxX maxY $ (Set.insert (nX, nY) nodes)
    where (aX, aY) = a
          nX = 2 * x - aX
          nY = 2 * y - aY

getAntinodesForFrequency :: [(Int, Int)] -> [(Int, Int)] -> Int -> Int -> Set.Set (Int, Int) -> Set.Set (Int, Int)
getAntinodesForFrequency [] _ _ _ nodes = nodes
getAntinodesForFrequency (a:as) allAntennas maxX maxY nodes = getAntinodesForFrequency as allAntennas maxX maxY $ getAntinodesForAntenna x y allAntennas maxX maxY nodes
    where (x, y) = a

getAntinodes :: [[(Int, Int)]] -> Int -> Int -> Set.Set (Int, Int) -> Set.Set (Int, Int)
getAntinodes [] _ _ nodes = nodes
getAntinodes (f:fs) maxX maxY nodes = getAntinodes fs maxX maxY $ getAntinodesForFrequency f f maxX maxY nodes

main :: IO ()
main = do
    content <- readFile "input.txt"
    let rows = lines content
        coords = parseLines rows 0 Map.empty
        maxX = length (head rows) - 1
        maxY = length rows - 1
        antinodes = getAntinodes (Map.elems coords) maxX maxY Set.empty
    print $ length antinodes
