<template>
  <div class="ele-projects-card">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <template v-if="where.projectType === '1'">
            <el-col :lg="6" :md="12">
              <el-form-item label="患者姓名:">
                <el-input
                  clearable
                  v-model="where.patientName"
                  placeholder="请输入患者姓名"/>
              </el-form-item>
            </el-col>
          </template>
          <template v-else>
            <el-col :lg="6" :md="12">
              <el-form-item label="组织名称:">
                <el-input
                  clearable
                  v-model="where.organizationName"
                  placeholder="请输入筹款组织名称"/>
              </el-form-item>
            </el-col>
          </template>
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="全部"
                class="ele-fluid">
                <el-option label="未审核" value="1"/>
                <el-option label="已打款" value="2"/>
                <el-option label="已拒绝" value="3"/>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload">查询
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
        height="calc(100vh - 355px)">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <!--          <el-button-->
          <!--            size="small"-->
          <!--            type="primary"-->
          <!--            icon="el-icon-plus"-->
          <!--            class="ele-btn-icon"-->
          <!--            @click="rowEdit(null)">新增-->
          <!--          </el-button>-->
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{row}">
          <el-link
            :underline="false"
            icon="el-icon-view"
            @click="rowEdit(row, 'detail')">查看详情
          </el-link>
          <el-link
            :underline="false"
            icon="el-icon-tickets"
            @click="rowEdit(row, 'history')">历史提款
          </el-link>
        </template>
        <!-- 地区列 -->
        <template slot="city" slot-scope="{row}">
          {{ (row.province ? row.province : '') + (row.city ? row.city : '') + (row.district ? row.district : '') }}
        </template>
        <!-- 经济情况列 -->
        <template slot="economic" slot-scope="{row}">
          <el-tag
            v-if="row.economicCondition"
            size="mini">{{ row.economicCondition }}
          </el-tag>
          <el-tag
            v-if="row.builtHouse"
            size="mini">{{ row.builtHouse }}
          </el-tag>
          <el-tag
            v-if="row.commercialHouse"
            size="mini">{{ row.commercialHouse }}
          </el-tag>
        </template>
        <!-- 筹款周期列 -->
        <template slot="rangeDate" slot-scope="{row}">
          {{ row.startDate }} 至 {{ row.endDate }}
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{row}">
          <el-tag
            :type="row.status === 1 ? 'info' : (row.status === 2 ? '' : 'danger')"
            size="mini">{{ row.statusName }}
          </el-tag>
        </template>
      </ele-pro-table>
    </el-card>
  </div>
</template>

<script>
import {mapGetters} from "vuex";
import regions from 'ele-admin/packages/regions';
import * as $util from 'ele-admin/packages/util.js';

const columns_person = [
  // {
  //   columnKey: 'selection',
  //   type: 'selection',
  //   width: 45,
  //   align: 'center',
  //   fixed: "left"
  // },
  {
    prop: 'id',
    label: 'ID',
    width: 60,
    align: 'center',
    showOverflowTooltip: true,
    fixed: "left"
  },
  {
    prop: 'createdAt',
    label: '申请时间',
    sortable: 'custom',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
    formatter: (row, column, cellValue) => {
      return $util.toDateString(cellValue);
    }
  },
  {
    prop: 'patientName',
    label: '患者姓名',
    showOverflowTooltip: true,
    minWidth: 150,
    align: 'center',
  },
  {
    prop: 'patientIdNo',
    label: '患者证件号',
    showOverflowTooltip: true,
    minWidth: 150,
    align: 'center',
  },
  {
    prop: 'disease',
    label: '所患疾病',
    showOverflowTooltip: true,
    minWidth: 200,
    align: 'center',
  },
  {
    prop: 'contactPhone',
    label: '手机号码',
    showOverflowTooltip: true,
    minWidth: 200,
    align: 'center',
  },
  {
    prop: 'amount',
    label: '申请金额',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'remainAmount',
    label: '剩余捐款',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'applyNum',
    label: '申请次数',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'status',
    label: '状态',
    align: 'center',
    width: 150,
    resizable: false,
    slot: 'status',
  },
  {
    prop: 'paymentAt',
    label: '打款时间',
    sortable: 'custom',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
    formatter: (row, column, cellValue) => {
      return $util.toDateString(cellValue);
    }
  },
  {
    columnKey: 'action',
    label: '操作',
    width: 225,
    align: 'center',
    resizable: false,
    slot: 'action',
    fixed: "right"
  }
];

const columns_org = [
  {
    prop: 'id',
    label: 'ID',
    width: 60,
    align: 'center',
    showOverflowTooltip: true,
    fixed: "left"
  },
  {
    prop: 'createdAt',
    label: '申请时间',
    sortable: 'custom',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
    formatter: (row, column, cellValue) => {
      return $util.toDateString(cellValue);
    }
  },
  {
    prop: 'organizationName',
    label: '组织机构名称',
    showOverflowTooltip: true,
    minWidth: 150,
    align: 'center',
  },
  {
    prop: 'contactPhone',
    label: '手机号码',
    showOverflowTooltip: true,
    minWidth: 200,
    align: 'center',
  },
  {
    prop: 'amount',
    label: '申请金额',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'remainAmount',
    label: '剩余捐款',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'applyNum',
    label: '申请次数',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
  },
  {
    prop: 'status',
    label: '状态',
    align: 'center',
    width: 150,
    resizable: false,
    slot: 'status',
  },
  {
    prop: 'paymentAt',
    label: '打款时间',
    sortable: 'custom',
    showOverflowTooltip: true,
    minWidth: 160,
    align: 'center',
    formatter: (row, column, cellValue) => {
      return $util.toDateString(cellValue);
    }
  },
  {
    columnKey: 'action',
    label: '操作',
    width: 225,
    align: 'center',
    resizable: false,
    slot: 'action',
    fixed: "right"
  }
];

export default {
  name: 'CfProjectsCard',
  props: {
    projectType: {
      type: String,
      default: '1'
    },
  },
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格数据接口
      url: '/cfProjectsWithdraw/index',
      // 表格列配置
      columns: this.projectType === '1' ? columns_person : columns_org,
      // 组织机构列表
      // columns_org: ,
      // 表格搜索条件
      where: {
        projectType: this.projectType
      },
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
    };
  },
  mounted() {
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
    },
    /* 重置搜索 */
    reset() {
      this.where = {projectType: this.where.projectType};
      this.reload();
    },
    // onProjectTypeChange() {
    //   this.reload();
    // },
    /* 显示编辑 */
    rowEdit(row, type) {
      this.$emit('rowEdit', {row, type});
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({lock: true});
      this.$http.post('/cfProjectsWithdraw/delete', [row.id]).then(res => {
        loading.close();
        if (res.data.code === 200) {
          this.$message.success(res.data.message);
          this.reload();
        } else {
          this.$message.error(res.data.message);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error('请至少选择一条数据');
        return;
      }
      this.$confirm('确定要删除选中的项目吗?', '提示', {
        type: 'warning'
      }).then(() => {
        const loading = this.$loading({lock: true});
        this.$http.post('/cfProjectsWithdraw/delete', this.selection.map(d => d.id)).then(res => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          loading.close();
          this.$message.error(e.message);
        });
      }).catch(() => {
      });
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({lock: true});
      let params = Object.assign({
        "id": row.id,
        "status": row.status
      })
      this.$http.post('/cfProjectsWithdraw/status', params).then(res => {
        loading.close();
        if (res.data.code === 200) {
          this.$message.success(res.data.message);
        } else {
          row.status = !row.status ? 1 : 2;
          this.$message.error(res.data.message);
        }
      }).catch(e => {
        loading.close();
        this.$message.error(e.message);
      });
    },
  }
}
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
