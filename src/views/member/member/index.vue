<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent
      >
        <el-row :gutter="15">
          <el-col :lg="6" :md="12">
            <el-form-item label="会员账号:">
              <el-input
                clearable
                v-model="where.username"
                placeholder="请输入会员账号"
              />
            </el-form-item>
          </el-col>
          <!--          <el-col :lg="6" :md="12">-->
          <!--            <el-form-item label="性别:">-->
          <!--              <el-select-->
          <!--                clearable-->
          <!--                v-model="where.gender"-->
          <!--                placeholder="请选择性别"-->
          <!--                class="ele-fluid">-->
          <!--                <el-option label="男" value="1"/>-->
          <!--                <el-option label="女" value="2"/>-->
          <!--              </el-select>-->
          <!--            </el-form-item>-->
          <!--          </el-col>-->
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload"
                >查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        :selection.sync="selection"
        height="calc(100vh - 315px)"
      >
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button
            @click="openEdit(null)"
            type="primary"
            icon="el-icon-plus"
            class="ele-btn-icon"
            size="small"
            v-if="permission.includes('sys:member:add')"
            >添加
          </el-button>
          <el-button
            @click="removeBatch"
            type="danger"
            icon="el-icon-delete"
            class="ele-btn-icon"
            size="small"
            v-if="permission.includes('sys:member:dall')"
            >删除
          </el-button>
        </template>
        <!-- 性别列 -->
        <template slot="gender" slot-scope="{ row }">
          <el-tag
            :type="['success', 'primary', 'warning'][row.gender - 1]"
            size="mini"
          >
            {{ ["男", "女", "保密"][row.gender - 1] }}
          </el-tag>
        </template>
        <template v-slot:isAgent="{ row }">
          <el-tag :type="row.isAgent ? 'success' : 'danger'" size="mini">
            {{ row.isAgent ? "是" : "否" }}
          </el-tag>
        </template>
        <!-- 头像 -->
        <template slot="avatar" slot-scope="{ row }">
          <el-avatar shape="square" :size="25" :src="row.avatar" />
        </template>
        <!-- 设备类型列 -->
        <template slot="device" slot-scope="{ row }">
          <el-tag
            :type="
              ['primary', 'success', 'warning', 'danger', 'info'][
                row.device - 1
              ]
            "
            size="mini"
          >
            {{ ["苹果", "安卓", "WAP站", "PC站", "后台"][row.device - 1] }}
          </el-tag>
        </template>
        <!-- 注册来源列 -->
        <template slot="source" slot-scope="{ row }">
          <el-tag
            :type="
              ['primary', 'success', 'warning', 'danger', 'info'][
                row.source - 1
              ]
            "
            size="mini"
          >
            {{
              ["APP注册", "小程序注册", "网站注册", "WAP站注册", "马甲会员"][
                row.source - 1
              ]
            }}
          </el-tag>
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{ row }">
          <el-switch
            v-model="row.status"
            @change="editStatus(row)"
            :active-value="1"
            :inactive-value="2"
          />
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row,$index }">
          <el-link
            type="primary"
            :underline="false"
            icon="el-icon-edit"
            @click="openEdit(row)"
            >修改
          </el-link>
          <el-link
            type="warning"
            :underline="false"
            v-if="permission.includes('sys:member:edit')"
            :icon="!row['isAgent'] ? 'el-icon-star-on' : 'el-icon-star-off'"
            @click="setAgent(row, !row['isAgent'],$index)"
          >
            {{ !row["isAgent"] ? "设为代理" : "取消代理" }}
          </el-link>
          <el-popconfirm
            class="ele-action"
            title="确定要删除此会员吗？"
            @confirm="remove(row)"
          >
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete"
              >删除
            </el-link>
          </el-popconfirm>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <member-edit :data="current" :visible.sync="showEdit" @done="reload" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import MemberEdit from "./member-edit";

export default {
  name: "Member",
  components: { MemberEdit },
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/cfUsers/index",
      // 表格列配置
      columns: [
        {
          columnKey: "selection",
          type: "selection",
          width: 45,
          align: "center",
          fixed: "left",
        },
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          prop: "username",
          label: "会员账号",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 110,
        },
        {
          prop: "nickname",
          label: "会员姓名",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 100,
        },
        {
          prop: "isAgent",
          label: "是否为代理",
          align: "center",
          width: 150,
          slot: "isAgent",
        },
        // {
        //   prop: 'nickname',
        //   label: '会员昵称',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   minWidth: 100
        // },
        {
          columnKey: "avatar",
          label: "头像",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 80,
          slot: "avatar",
        },
        // {
        //   prop: 'gender',
        //   label: '性别',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   minWidth: 60,
        //   slot: 'gender'
        // },
        // {
        //   prop: 'device',
        //   label: '设备类型',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   minWidth: 100,
        //   slot: 'device'
        // },
        // {
        //   prop: 'source',
        //   label: '注册来源',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   minWidth: 100,
        //   slot: 'source'
        // },

        {
          prop: "createdAt",
          label: "注册时间",
          align: "center",
          showOverflowTooltip: true,
          width: 160,
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          prop: "updatedAt",
          label: "更新时间",
          align: "center",
          showOverflowTooltip: true,
          width: 160,
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 80,
          resizable: false,
          slot: "status",
        },
        {
          columnKey: "action",
          label: "操作",
          width: 250,
          align: "center",
          resizable: false,
          slot: "action",
          fixed: "right",
        },
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showEdit: false,
      // 是否显示导入弹窗
      showImport: false,
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({ where: this.where });
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .delete("/member/delete/" + [row.id])
        .then((res) => {
          loading.close();
          if (res.data.code === 0) {
            this.$message.success(res.data.msg);
            this.reload();
          } else {
            this.$message.error(res.data.msg);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error("请至少选择一条数据");
        return;
      }
      this.$confirm("确定要删除选中的会员吗?", "提示", {
        type: "warning",
      })
        .then(() => {
          const loading = this.$loading({ lock: true });
          this.$http
            .delete("/member/delete/" + [this.selection.map((d) => d.id)])
            .then((res) => {
              loading.close();
              if (res.data.code === 0) {
                this.$message({ type: "success", message: res.data.msg });
                this.reload();
              } else {
                this.$message.error(res.data.msg);
              }
            })
            .catch((e) => {
              loading.close();
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: row.status,
      });
      this.$http
        .put("/member/status", params)
        .then((res) => {
          loading.close();
          if (res.data.code === 0) {
            this.$message({ type: "success", message: res.data.msg });
          } else {
            row.status = !row.status ? 1 : 2;
            this.$message.error(res.data.msg);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /**设置为代理*/
    setAgent(row, isAgent) {
      const loading = this.$loading({ lock: true });

      this.$http
        .post(`/cfUsers/${row.id}/agent-status?isAgent=${+isAgent}`)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message({
              type: "success",
              message: res.data.data ? "设置成功" : "设置失败",
            });
            this.$set(row, "isAgent", isAgent);
          } else {
            this.$message.error(res.data.msg);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style scoped></style>
