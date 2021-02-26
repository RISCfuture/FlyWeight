module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  extends: [
    'airbnb-base',
    'plugin:import/typescript'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    ecmaFeatures: {
      jsx: false
    },
    sourceType: 'module'
  },
  plugins: [
    '@typescript-eslint'
  ],
  rules: {
    '@typescript-eslint/consistent-type-assertions': ['error', { assertionStyle: 'angle-bracket' }],
    '@typescript-eslint/no-non-null-assertion': 'off',
    'arrow-parens': ['error', 'as-needed'],
    'comma-dangle': ['error', 'never'],
    'implicit-arrow-linebreak': 'off',
    'import/order': ['error', { groups: ['builtin', 'external', 'parent', 'sibling', 'index'] }],
    'import/no-named-default': 'off',
    'max-classes-per-file': 'off',
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-plusplus': 'off',
    'no-useless-constructor': 'off',
    semi: ['error', 'never']
  },
  settings: {
    'import/resolver': {
      typescript: {}
    }
  }
}
