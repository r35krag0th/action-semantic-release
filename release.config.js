module.exports = {
  branches: [
    '+([0-9])?(.{+([0-9]),x}).x',
    'main',
    'master',
    'next',
    'next-major',
    { name: 'beta', prerelease: true },
    { name: 'alpha', prerelease: true },
  ],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { type: 'breaking', release: 'major' },
          { type: 'feat', release: 'minor' },
          { type: 'fix', release: 'patch' },
          { type: 'docs', release: 'patch' },
          { type: 'style', release: 'patch' },
          { type: 'refactor', release: 'patch' },
          { type: 'perf', release: 'patch' },
          { type: 'test', release: 'patch' },
          { type: 'build', release: 'patch' },
          { type: 'ci', release: 'patch' },
          { type: 'chore', release: 'patch' }
        ]
      }
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        presetConfig: {
          types: [
            { type: 'feat', section: '✨ Features' },
            { type: 'fix', section: '🐛 Bug Fixes' },
            { type: 'docs', section: '📖 Documentation' },
            { type: 'style', section: '🖌️Styles' },
            { type: 'refactor', section: '💪 Code Refactoring' },
            { type: 'perf', section: '🏃 Performance Improvements' },
            { type: 'test', section: '🧪 Tests' },
            { type: 'build', section: '🏗️ Build System' },
            { type: 'ci', section: '🔄 Continuous Integration' },
            { type: 'chore', section: '🧼 Chores' },
            { type: 'deps', section: '🔧 Dependencies' }
          ]
        }
      }
    ],
    [
      '@semantic-release/exec',
      {
        analyzeCommitsCmd: "echo \"${lastRelease.version}\" > LAST_VERSION.txt",
        verifyReleaseCmd: "echo \"${nextRelease.version}\" > VERSION.txt"
      }
    ],
    [
      '@semantic-release/github'
    ]
  ]
}
