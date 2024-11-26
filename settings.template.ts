import Settings from './src/settings';

export default {
  gitlab: {
    url: 'https://gitlab.avantio.com',
    token: 'GITLAB_TOKEN',
    projectId: 0,
    listArchivedProjects: false,
    sessionCookie: "",
  },
  github: {
    baseUrl: 'https://github.com',
    apiUrl: 'https://api.github.com',
    owner: 'Avantio',
    ownerIsOrg: true,
    token: 'GITHUB_TOKEN',
    token_owner: 'avantio-bot',
    repo: 'REPLACE_ME',
    recreateRepo: false,
  },
  usermap: {
  projectmap: {
    'gitlabgroup/projectname.1': 'GitHubOrg/projectname.1',
    'gitlabgroup/projectname.2': 'GitHubOrg/projectname.2',
  },
  conversion: {
    useLowerCaseLabels: true,
  },
  transfer: {
    description: false,
    milestones: true,
    labels: true,
    issues: true,
    mergeRequests: true,
    releases: true,
  },
  dryRun: false,
  exportUsers: true,
  useIssueImportAPI: true,
  usePlaceholderMilestonesForMissingMilestones: true,
  usePlaceholderIssuesForMissingIssues: true,
  useReplacementIssuesForCreationFails: true,
  useIssuesForAllMergeRequests: false,
  filterByLabel: undefined,
  trimOversizedLabelDescriptions: false,
  skipMergeRequestStates: [],
  skipMatchingComments: [],
  mergeRequests: {
    logFile: './merge-requests.json',
    log: false,
  },
} as Settings;
