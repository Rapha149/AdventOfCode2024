module Main where
import qualified Data.Map as Map

height = 7

parseContent :: [String] -> [[Int]] -> [[Int]] -> ([[Int]], [[Int]])
parseContent [] locks keys = (locks, keys)
parseContent ls locks keys = parseContent ls' (if isLock then lengths : locks else locks) (if isLock then keys else lengths : keys)
    where isLock = ls !! 0 !! 0 == '#'
          c = if isLock then '.' else '#'
          i' = if isLock then 1 else -1
          (lengths, ls') = parse ls (if isLock then 0 else height) Map.empty
          parse :: [String] -> Int -> Map.Map Int Int -> ([Int], [String])
          parse [] _ lengthMap = (Map.elems lengthMap, [])
          parse (l:ls) i lengthMap | l == "" = (Map.elems lengthMap, ls)
                                   | otherwise = parse ls (i + i') $ foldr (\(k, _) -> Map.insertWith seq k i) lengthMap $ filter ((== c) . snd) $ zip [0..] l

main :: IO ()
main = do
    content <- readFile "input.txt"
    let (locks, keys) = parseContent (lines content) [] []
    print $ length $ filter (all (\(l, k) -> l + k <= height)) $ [zip lock key | lock <- locks, key <- keys]
