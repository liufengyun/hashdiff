require 'spec_helper'

describe HashDiff do
  it 'can do unsorted diff' do
    a = { "a": "b", "c": ["a", "b"]}
    b = { "a": "b", "c": ["b", "a"]}

    expect(HashDiff.diff(a, b)).to eq([["+", "c[0]", "b"], ["-", "c[2]", "b"]])
  end

  it 'can do sorted diff' do
    a = { "a": "b", "c": ["a", "b"]}
    b = { "a": "b", "c": ["b", "a"]}

    expect(HashDiff.diff(a, b, sort: true)).to eq([])
  end

  it 'can do sorted diff for complex nested structure' do
    a = { "a": "b", "c": ["a", "b"], "d": { "a": "b", "c": ["b", "a"]}}
    b = { "c": ["b", "a"], "a": "b", "d": { "a": "b", "c": ["a", "b"]}}

    expect(HashDiff.diff(a, b, sort: true)).to eq([])
  end

  it 'can do sort on array of hashes' do
    a = { "a": "b", "c": [{ "a": "b", "c": ["a", "b"], "d": { "a": "b", "c": ["b", "a"]}}, { "a": "b", "c": ["b", "a"], "d": { "a": "b", "c": ["a", "b"]}}], "d": { "a": "b", "c": ["b", "a"]}}
    b = { "a": "b", "c": [{ "c": ["b", "a"], "a": "b", "d": { "a": "b", "c": ["a", "b"]}}, { "a": "b", "c": ["a", "b"], "d": { "a": "b", "c": ["b", "a"]}}], "d": { "a": "b", "c": ["a", "b"]}}

    expect(HashDiff.diff(a, b, sort: true)).to eq([])
  end

  it 'identifies difference with sorting' do
    a = { "a": "b", "c": [{ "a": "b", "c": ["a", "b"], "d": { "a": "X", "c": ["b", "a"]}}, { "a": "b", "c": ["b", "a"], "d": { "a": "b", "c": ["a", "b"]}}], "d": { "a": "b", "c": ["b", "a"]}}
    b = { "a": "b", "c": [{ "c": ["b", "a"], "a": "b", "d": { "a": "b", "c": ["a", "b"]}}, { "a": "b", "c": ["a", "b"], "d": { "a": "b", "c": ["b", "a"]}}], "d": { "a": "b", "c": ["a", "b"]}}

    expect(HashDiff.diff(a, b, sort: true)).to eq([["~", "c[0].d.a", "X", "b"]])
  end
end
