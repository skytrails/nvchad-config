export default {
  user: state => state.user,
  userId: state => state.user.user.id,
  theme: state => state.theme,
  permission: state => state.user.permission,
  roles: state => state.user.roles,
}
