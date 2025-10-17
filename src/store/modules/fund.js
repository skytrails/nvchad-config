import axios from "axios";

export default {
  namespaced: true,
  state: {
    fundList: [],
  },
  mutations: {
    // 修改值
    SET_FUND_LIST(state, obj) {
      state.fundList = obj;
    },
  },
  actions: {
    /**
     * 设置节点权限
     * @param {*} commit
     * @param {*} data
     */
    async getFundList({ commit }, id) {
      try {
        axios.get("/fundList/getAll", { params: { id } }).then((res) => {
          commit("SET_FUND_LIST", res.data.data);
        });
      } catch (error) {
        console.log('error',error)
        commit("SET_FUND_LIST", []);
      }
    }
  },
};
